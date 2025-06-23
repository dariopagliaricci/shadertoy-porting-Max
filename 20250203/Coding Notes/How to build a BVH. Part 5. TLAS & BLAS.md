In the final two articles we explore how to build a BVH for a fully dynamic scene, using the same techniques employed by modern games: the _top level acceleration structure_ and the _bottom level acceleration structure._

## Mise en Place

As usual we’ll start with some preparations – an approach, I recently learned, called ‘mise en place’ in the French cuisine, which apparently [also works for programming](https://buttondown.email/hillelwayne/archive/software-mise-en-place/). For today’s main dish we will need multiple BVHs, so it is time to bring a tiny bit of OOP to the code (just a pinch should do). Let’s add a proper BVH class to encapsulate the `BVHNode` pool, triangle indices and a triangle list:

```cpp
class BVH
{
public:
    BVH() = default;
    BVH( char* triFile, int N );
    void Build();
    void Refit();
    void Intersect( Ray& ray );
private:
    void Subdivide( uint nodeIdx );
    void UpdateNodeBounds( uint nodeIdx );
    float FindBestSplitPlane( BVHNode& node, int& axis, float& splitPos );
    BVHNode* bvhNode = 0;
    Tri* tri = 0;
    uint* triIdx = 0;
    uint nodesUsed, triCount;
};
```

A lot of functionality we implemented before is moved to this class, in general without (much) modifications. I made some changes to the names of the methods: `BuildBVH()` is now `BVH::Build()`, `RefitBVH()` is now `BVH::Refit()`, and `IntersectBVH(...)` is now `BVH::Intersect(...)`. Methods that are not to be called outside the BVH class are declared private. The data is also private. Loading the scene is now handled by the constructor of the BVH class:

```cpp
BVH::BVH( char* triFile, int N )
{
    FILE* file = fopen( triFile, "r" );
    triCount = N;
    tri = new Tri[N];
    for (int t = 0; t < N; t++) fscanf( file, "%f %f %f %f %f %f %f %f %f\n",
        &tri[t].vertex0.x, &tri[t].vertex0.y, &tri[t].vertex0.z,
        &tri[t].vertex1.x, &tri[t].vertex1.y, &tri[t].vertex1.z,
        &tri[t].vertex2.x, &tri[t].vertex2.y, &tri[t].vertex2.z );
    bvhNode = (BVHNode*)_aligned_malloc( sizeof( BVHNode ) * N * 2, 64 );
    triIdx = new uint[N];
    Build();
}
```

The global scope definition of `N` (the number of triangles in the mesh) is now passed to the constructor, because I insist on keeping file loading as basic as possible.

With the newly created BVH class, we can now reduce the global application data to:

```cpp
// application data
BVH bvh;
```

…which we initialize in the `TopLevelApp::Init()` function:
```cpp
void TopLevelApp::Init()
{
    bvh = BVH( "assets/armadillo.tri", 30000 );
}
```

OOP has its merits; this is tidy. Plus, we are now ready to add more meshes. Intersecting these efficiently is going to be the first step; after that, we will also animate them efficiently, all using some quite beautiful constructs, commonly referred to as the TLAS and BLAS.

## Two Armadillos

Now that the BVH data and logic is properly stored in a class, we can easily add a second mesh:
```cpp
void TopLevelApp::Init()
{
    bvh[0] = BVH( "assets/armadillo.tri", 30000 );
    bvh[1] = BVH( "assets/armadillo.tri", 30000 );
}
```

This is not terribly useful: both armadillos will be at the same location. We could solve this by adding an offset to the vertices of each armadillo. The next issue is the calculation of an intersection. This is not too hard either: calling `BVH::Intersect()` with a ray updates the intersection `t` for that ray; we can thus call this function once for each armadillo. That does work, but it seems impractical for a scene with more than a couple armadillos… And while we are pointing out problems with the current plan: why do we store the armadillo twice, while all the polygons are the same?

Let’s start with that last question. To move an armadillo, we can add a translation to every vertex of the mesh. Or, and that is a tantalizing alternative: we can move the _camera_ with the _inverse_ of the same translation.

![](https://raw.githubusercontent.com/jbikker/ompf2/main/scenery.jpg)

Is the train moving to the left, or is the landscape moving to the right? Doesn’t matter, it’s all the same. 

So instead of loading the armadillo twice, and moving one of them, and intersecting them one at a time, we can do something clever:

```cpp
void TopLevelApp::Tick( float deltaTime )
{
    float3 p0( -1, 1, 2 ), p1( 1, 1, 2 ), p2( -1, -1, 2 );
    for (int tile = 0; tile < 6400; tile++)
    {
        int x = tile % 80, y = tile / 80;
        Ray ray;
        for (int v = 0; v < 8; v++) for (int u = 0; u < 8; u++)
        {
            float3 pixelPos = ray.O + p0 +
                (p1 - p0) * ((x * 8 + u) / 640.0f) +
                (p2 - p0) * ((y * 8 + v) / 640.0f);
            ray.D = normalize( pixelPos - ray.O ), ray.t = 1e30f;
            ray.rD = float3( 1 / ray.D.x, 1 / ray.D.y, 1 / ray.D.z );
            ray.O = float3( -1, 0.5f, -4.5f );
            bvh.Intersect( ray );
            ray.O = float3( 1, 0.5f, -4.5f );
            bvh.Intersect( ray );
            uint c = ray.t < 1e30f ? (255 - (int)((ray.t - 3) * 80)) : 0;
            screen->Plot( x * 8 + u, y * 8 + v, c * 0x10101 );
       }
    }
}
```

Here, the _same_ BVH is intersected _twice_, with the same ray even, but between invocations of `bvh.Intersect(ray)`, we _change_ the ray. By moving the ray a bit to the left, we effectively move the scene to the right. Then, by moving the ray to the right, we move the scene to the left. The result is a scene with two armadillos.

![](https://raw.githubusercontent.com/jbikker/ompf2/main/twins.png)

We can take this one step further. Moving the ray in the opposite direction of a mesh can be applied to translations as well as orientations. Concrete and formal: 

**_Given a mesh with a BVH built in object space and 4×4 matrix that stores orientation and translation for the mesh, we can intersect its BVH in world space by applying the inverse transform to the rays._** 

![](https://raw.githubusercontent.com/jbikker/ompf2/main/racinggame.jpg)

Recall the race game scenario. The track is stationary (it uses the identity matrix), but the cars use matrices to zip around. And the car tires use matrices relative to the car. 

This may sound complex, but it is very powerful. In any 3D engine, the meshes of the scene hierarchy come with their own 4×4 matrix. To ray trace these meshes, we simply transform rays using the inverse matrix. This still works if the matrix changes from one frame to another: mesh motion defined by a matrix does not require a rebuild or refit, and is essentially free.

## Spinning Armadillos

It is time to add this functionality to the BVH class. We will need a few things:

- Storage for the transformation matrix (4×4, so it includes rotation and translation, potentially also scaling and shearing).
- Storage for the bounds of the BVH in world space. This will be important for constructing the TLAS later.

The new fields are named `invTransform` and `bounds`:

```cpp
mat4 invTransform; // inverse transform
aabb bounds; // in world space
```

Note that we don’t actually store the transformation matrix: we store its inverse. Inverting a matrix is somewhat costly, so we don’t want to do this for every ray.

The new fields are filled using a new method:
```cpp
void BVH::SetTransform( mat4& transform )
{

    invTransform = transform.Inverted();
    // calculate world-space bounds using the new matrix
    float3 bmin = bvhNode[0].aabbMin, bmax = bvhNode[0].aabbMax;
    bounds = aabb();
    for( int i = 0; i < 8; i++ )
        bounds.grow( TransformPosition( float3( i & 1 ? bmax.x : bmin.x,
            i & 2 ? bmax.y : bmin.y, i & 4 ? bmax.z : bmin.z ), transform ) );
}
```


This is some pretty dense code, so allow me to explain. First, as promised, the `invTransform` field is set using the inverted 4×4 matrix. After this we calculate the bounding box for the transformed bounding box of the object. This sounds strange, but it is quite useful: The only way to detect if a ray misses a BVH is by checking its root node against the ray. In the case of a transformed BVH, this already requires transformation of the ray. Storing (the AABB of) the transformed bounds of the BVH root node allows us to do an early ‘hit/miss’ test using the original ray. The AABB is likely going to be too large, but that’s OK: at least it lets us efficiently ignore BVHs that a ray does not even get close to. In the actual code, the `for` loop calculates the 8 unique combinations of x, y and z from `aabbMin` and `aabbMax` of the root node; these combinations represent the 8 corners of the root AABB.

Using the inverted transform we can now make the required modifications to BVH::Traverse.

```cpp
void BVH::Intersect( Ray& ray )
{
    // backup ray and transform original
    Ray backupRay = ray;
    ray.O = TransformPosition( ray.O, invTransform );
    ray.D = TransformVector( ray.D, invTransform );
    ray.rD = float3( 1 / ray.D.x, 1 / ray.D.y, 1 / ray.D.z );
    // trace transformed ray
 
    ....
 
    // restore ray origin and direction
    backupRay.t = ray.t;
    ray = backupRay;
}
```


The ray that is about to intersect the BVH first gets copied, so we can restore it later: we may wish to intersect the same ray with another BVH. After that we transform the ray origin and direction, and recalculate the reciprocals of the direction. With the transformed ray we then traverse the BVH in the usual manner.

Maths note: the ray origin is a position; to transform it using a matrix we should apply rotation and translation. We thus use a homogeneous coordinate with 1 for the w component. The ray direction on the other hand should be rotated but not translated; it is thus turned into a homogeneous coordinate with 0 for the w component. The `TransformPosition` and `TransformVector` functions reflect this difference.

At the end of the code we restore the original ray, except for one field: the t value, which represents the nearest intersection distance.

With the proposed modifications, the `Tick` function now becomes quite a bit more elegant:
```cpp
void TopLevelApp::Tick( float deltaTime )
{
    float3 p0( -1, 1, 2 ), p1( 1, 1, 2 ), p2( -1, -1, 2 );
    static float angle = 0;
    angle += 0.01f; if (angle > 2 * PI) angle -= 2 * PI;
    bvh[0].SetTransform( mat4::Translate( float3( -1.3f, 0, 0 ) ) );
    bvh[1].SetTransform( mat4::Translate( float3( 1.3f, 0, 0 ) ) 
                       * mat4::RotateY( angle ) );
#pragma omp parallel for schedule(dynamic)
    for (int tile = 0; tile < 6400; tile++)
    {
        int x = tile % 80, y = tile / 80;
        Ray ray;
        ray.O = float3( 0, 0.5f, -4.5f );
        for (int v = 0; v < 8; v++) for (int u = 0; u < 8; u++)
        {
            float3 pixelPos = ray.O + p0 +
                (p1 - p0) * ((x * 8 + u) / 640.0f) +
                (p2 - p0) * ((y * 8 + v) / 640.0f);
            ray.D = normalize( pixelPos - ray.O ), ray.t = 1e30f;
            ray.rD = float3( 1 / ray.D.x, 1 / ray.D.y, 1 / ray.D.z );
            bvh[0].Intersect( ray );
            bvh[1].Intersect( ray );
            uint c = ray.t < 1e30f ? (255 - (int)((ray.t - 3) * 80)) : 0;
            screen->Plot( x * 8 + u, y * 8 + v, c * 0x10101 );
        }
    }
}
```

Note how `bvh[0]` is transformed to the left using a translation matrix. For `bvh[1]` we use a concatenated matrix, consisting of a rotation around the y-axis followed by a translation to the right.

## Many Armadillos

With the code we have so far we can conveniently spin and move models, without rebuilding or refitting their BVHs. But what if we have _a lot of_ Armadillos? This is where the top level acceleration structure comes in.

It starts with the notion that a pair of BVHs can be combined into a single BVH, by simply adding one new node, that has the pair of BVHs as child nodes. We now have a new, valid BVH that we can traverse as if it were a regular BVH. If we combine this with the concept of transformed BVHs, we get something very powerful. The nodes that we use to combine a set of BVHs into a single BVH are referred to as the top level acceleration structure, or TLAS. It effectively helps us to hierarchically cull groups of objects, just like we culled groups of triangles using the BVH.

Let’s start with the definition of a TLAS node:

```cpp
struct TLASNode
{
    float3 aabbMin;
    uint leftBLAS;
    float3 aabbMax;
    uint isLeaf;
};
```


This looks like a regular BVH node. The `leftFirst` field, which originally stored either the index of the left node, or the ‘index of the index’ of the first triangle, now stores a BLAS index: in our simple case with two BVHs, this would be either 0 or 1. In the TLAS, we will never have more than one BLAS in a leaf node, so indirection is not needed here. The `triCount`field is also not needed. Since we still need to know if this is a leaf node or not, we now simply use a boolean, encoded as a uint.

Also analogous to the original BVH we get a TLAS, which stores data related to the top level acceleration structure:

```cpp
TLAS::TLAS( BVH* bvhList, int N )
{
    // copy a pointer to the array of bottom level accstructs
    blas = bvhList;
    blasCount = N;
    // allocate TLAS nodes
    tlasNode = (TLASNode*)_aligned_malloc( sizeof( TLASNode ) * 2 * N, 64 );
    nodesUsed = 2;
}
```

The `tlasNode` field is a pool of nodes, analogous to the `bvhNode` array we used for constructing a BVH. The triangle array of the BVH is replaced by a BVH array. Each BVH is a bottom level acceleration structure, so we name this array `blas`.

Let’s build a minimal TLAS, before we get to more complex scenes.
```cpp
TLAS::TLAS( BVH* bvhList, int N )

{

    // copy a pointer to the array of bottom level accstructs

    blas = bvhList;

    blasCount = N;

    // allocate TLAS nodes

    tlasNode = (TLASNode*)_aligned_malloc( sizeof( TLASNode ) * 2 * N, 64 );

    nodesUsed = 2;

}
```

This is the constructor for the TLAS. It takes an array of BVHs (and since I stubbornly evade the use of a convenient vector here, `N` stores the BVH count), which we store in the TLAS object. A TLAS over `N` BVHs will consist of `2N-1` nodes, so we pre-allocate this set of nodes. And as usual, for cache alignment reasons, we skip `tlasNode[1]`, so the actual array has `2N`elements. Element 0 is, as usual, reserved for the root.

For just two BVHs we can build the TLAS manually.

```cpp
void TLAS::Build()
{
    // assign a TLASleaf node to each BLAS
    tlasNode[2].leftBLAS = 0;
    tlasNode[2].aabbMin = float3( -100 );
    tlasNode[2].aabbMax = float3( 100 );
    tlasNode[2].isLeaf = true;
    tlasNode[3].leftBLAS = 1;
    tlasNode[3].aabbMin = float3( -100 );
    tlasNode[3].aabbMax = float3( 100 );
    tlasNode[3].isLeaf = true;
    // create a root node over the two leaf nodes
    tlasNode[0].leftBLAS = 2;
    tlasNode[0].aabbMin = float3( -100 );
    tlasNode[0].aabbMax = float3( 100 );
    tlasNode[0].isLeaf = false;
}
```

Here, two TLAS leaf nodes are created, which reference BVH 0 and 1. The nodes have massive AABBs, to ensure that a ray will always intersect them. We’ll need to refine that later. The root node of the TLAS references child node 2 (and thus also 3), which we just created. The root also has a massive AABB, for now.

The TLAS is traversed like a regular BVH:

```cpp
void TLAS::Intersect( Ray& ray )
{
    TLASNode* node = &tlasNode[0], *stack[64];
    uint stackPtr = 0;
    while (1)
    {
        if (node->isLeaf)
        {
            blas[node->leftBLAS].Intersect( ray );
            if (stackPtr == 0) break; else node = stack[--stackPtr];
            continue;
        }
        TLASNode* child1 = &tlasNode[node->leftBLAS];
        TLASNode* child2 = &tlasNode[node->leftBLAS + 1];
        float dist1 = IntersectAABB( ray, child1->aabbMin, child1->aabbMax );
        float dist2 = IntersectAABB( ray, child2->aabbMin, child2->aabbMax );
        if (dist1 > dist2) { swap( dist1, dist2 ); swap( child1, child2 ); }
        if (dist1 == 1e30f)
        {
            if (stackPtr == 0) break; else node = stack[--stackPtr];
        }
        else
        {
            node = child1;
            if (dist2 != 1e30f) stack[stackPtr++] = child2;
        }
    }
}
```

The difference between TLAS traversal and BLAS traversal is in the leaf nodes. For the TLAS, a leaf contains a single BLAS, which we must intersect. After intersecting the BLAS, we still may need to intersect other BVHs (if they are closer than the nearest intersection so far), so the functionality that restores the ray after traversing a BVH comes in handy now.

Let’s put the TLAS/BLAS to the test. First, we create the TLAS in the `::Init` function:

```cpp
void TopLevelApp::Init()
{
    bvh[0] = BVH( "assets/armadillo.tri", 30000 );
    bvh[1] = BVH( "assets/armadillo.tri", 30000 );
    tlas = TLAS( bvh, 2 );
    tlas.Build();
}
```


Then, in the `::Tick` function, we replace the two calls to `BVH::Intersect(...)` by a single call to `TLAS::Intersect(...)`:

```cpp
tlas.Intersect( ray );
```

![](https://raw.githubusercontent.com/jbikker/ompf2/main/tlasaction.jpg)

And that is all. We now have two BVHs, nicely tucked away into a single structure, which we can intersect with a single call. We can still change the transforms for the BVHs, per frame if we wish, without any cost.

## Loose Ends

A lot remains to be done, but this is already a pretty long article. Next time we will fill in the details:

- Rebuilding the TLAS per frame
- Building a TLAS for lots of armadillos
- Proper AABBs in the TLAS
- Instancing, so we don’t have to load the armadillo twice
- Combining TLAS/BLAS with refitting and rebuilding

In short: [everything will come together](https://jacco.ompf2.com/2022/05/13/how-to-build-a-bvh-part-6-all-together-now/).