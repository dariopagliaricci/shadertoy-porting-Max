In this article we finalize the construction of the two-level acceleration structure for animated scenes.

## Half Baked

The conclusion of article 5 probably felt a bit underwhelming. The code handles no less than _two_ armadillos, which get intersected using a _single call_ to the Intersect method of TLAS, even if they _both_ get a new transformation matrix each frame. True, but… that’s not the kind of performance and versatility you may have been hoping for. It’s time to fulfill some promises.

Let’s formulate a target for this article, and then see how we can get there. The goal for today is to have 256 armadillos floating through space, while rotating, and bouncing off the walls of a virtual cube. For this, we will build a top-level structure over 256 bottom-level acceleration structures, in real-time. The total polygon count will be 30,000 times 256, so well over 7 million triangles. Once we reach this goal, it’s play time; we’ll be able to ray trace virtually anything – although a scene that can be intersected efficiently by rays must have certain characteristics. More on that at the end of the article.

## Proper TLAS Construction

Last time we built a TLAS over two BVHs. We did this by storing the two BVHs in TLAS leaf nodes; the two leaf nodes then became child nodes of a single TLAS root node.

For a larger number of BVHs we can use a similar technique. In short, we will combine pairs of nodes using a parent node; the parent node will then be paired with other leaf nodes or interior nodes, until we have just a single node left. This is then the root node.

To build an _optimal_ TLAS, the pairs that we create must be carefully chosen. It turns out that we should be pairing nodes that form small boxes – where ‘small’ actually means: having a small surface area. So, given 256 BVHs, we are looking for the two BVHs that, when put into a single AABB, have the smallest AABB. A simple algorithm will get the job done:

```cpp
for each BVH A
    find BVH B for which AABB(A,B) is smallest
    ```
    
This is an O(N2)O(N2) algorithm. However, we’re overlooking something: the algorithm gets us _one_ pair, which brings the number of nodes down to 255 (one is now an interior node). We need to do this 255 more times to get to a single root node. By then, the algorithm is O(N3)O(N3), which is bad, even on a fast machine and at a pretty low number of BVHs (such as 256).

Luckily, something better exists. For this, we need to look at a 2008 paper by Walter et al., titled _Fast Agglomerative Clustering for Rendering_. The term agglomerative clustering refers to the bottom-up process we’re using when we combine pairs of nodes; the alternative is the top-down process we used for constructing a BLAS over a group of triangles. The algorithm from the paper, in pseudo-code:

```cpp
TLASNode A = list.GetFirst();
TLASNode B = list.FindBestMatch( A );
while (list.size() > 1)
{
   TLASNode C = list.FindBestMatch( B );
   if (A == C)
   {
      list.Remove( A );
      list.Remove( B );
      A = new Node( A, B );
      list.Add( A );
      B = list.FindBestMatch( A );
   }
   else A = B, B = C;
}
```

If you try this out on a piece of paper you’ll see that this actually works. Performance is pretty good as well: we get close to O(N2)O(N2) in practice, which is quite acceptable for 256 armadillos.

Before we turn this into practical code we need to make a change to the `TLASNode` struct that was proposed in [article 5](https://jacco.ompf2.com/2022/05/07/how-to-build-a-bvh-part-5-tlas-blas/). The struct stores only the index of the left child, assuming that the right child can be derived from that. Using agglomerative clustering, this is no longer the case. Luckily, the required change is not too complex:

```cpp
struct TLASNode
{
    float3 aabbMin;
    uint leftRight; // 2x16 bits
    float3 aabbMax;
    uint BLAS;
    bool isLeaf() { return leftRight == 0; }
};
```

The 32-bit field `leftRight` now stores two numbers, in 2×16 bits. For leaf nodes, field `BLAS` stores the index of a BLAS, otherwise it is unused. We identify leaves by looking at `leftRight`: for interior nodes one of the child indices must be greater than zero, so only if we set `leftRight` to 0, we have a leaf node.

Back to TLAS construction. Construction starts with the 256 leaf nodes:

```cpp
void TLAS::Build()
{
    // assign a TLASleaf node to each BLAS
    nodesUsed = 1;
    for (uint i = 0; i < blasCount; i++)
    {
        tlasNode[nodesUsed].aabbMin = blas[i].bounds.bmin;
        tlasNode[nodesUsed].aabbMax = blas[i].bounds.bmax;
        tlasNode[nodesUsed].BLAS = i;
        tlasNode[nodesUsed++].leftRight = 0; // makes it a leaf
    }
    ...
```


As with a regular BVH, `tlasNode[0]` will contain the root. We create the root last, so we reserve space for it; the first node we will use as a leaf node is thus `tlasNode[1]` (indexed by `nodesUsed`). The AABB we use for each TLAS leaf node is obtained from the BVHs and is in world space. 

Now that we have the leaf nodes, we can create the work list for the agglomerative clustering algorithm:

```cpp
int nodeIdx[256], nodeIndices = blasCount;
```

Rather than directly storing the `TLASNode` instances, we store indices of elements of the `tlasNode` array. The number of nodes that still need to be paired is obtained from `blasCount`; for 256 armadillos this will simply be 256, and after each generated pair, it will decrement by 1 until only one node is left: this will be our root node.

The array can be initialized in the loop that creates the TLAS leaf nodes:

```cpp
void TLAS::Build()
{
    // assign a TLASleaf node to each BLAS
    int nodeIdx[256], nodeIndices = blasCount;
    nodesUsed = 1;
    for (uint i = 0; i < blasCount; i++)
    {
        nodeIdx[i] = nodesUsed;
        tlasNode[nodesUsed].aabbMin = blas[i].bounds.bmin;
        tlasNode[nodesUsed].aabbMax = blas[i].bounds.bmax;
        tlasNode[nodesUsed].BLAS = i;
        tlasNode[nodesUsed++].leftRight = 0; // makes it a leaf
    }
```

Everything is now ready for the actual clustering. The algorithm calls ‘FindBestMatch’ three times. This is the function that, given a TLASNode A, finds the node B (where B != A) that forms the smallest AABB with A. It is implemented as follows:

```cpp
int TLAS::FindBestMatch( int* list, int N, int A )
{
    float smallest = 1e30f;
    int bestB = -1;
    for (int B = 0; B < N; B++) if (B != A)
    {
        float3 bmax = fmaxf( tlasNode[list[A]].aabbMax, tlasNode[list[B]].aabbMax );
        float3 bmin = fminf( tlasNode[list[A]].aabbMin, tlasNode[list[B]].aabbMin );
        float3 e = bmax - bmin;
        float surfaceArea = e.x * e.y + e.y * e.z + e.z * e.x;
        if (surfaceArea < smallest) smallest = surfaceArea, bestB = B;
    }
    return bestB;
}
```

This function simply checks all remaining nodes in the list. For each node, the combined AABB is determined. If the area of this AABB (skipping the factor 2, as usual) is smaller than what we found before, we take note of that. After checking all nodes we return our best find.

Note the tricky addressing of the `tlasNode` array: since the work list contains `tlasNode` array indices, we need this complex indirection to query the correct nodes.

With the FindBestMatch function properly implemented, we can now finalize the agglomerative clustering algorithm.

```cpp
void TLAS::Build()
{
    // assign a TLASleaf node to each BLAS
    ...
    // use agglomerative clustering to build the TLAS
    int A = 0, B = FindBestMatch( nodeIdx, nodeIndices, A );
    while (nodeIndices > 1)
    {
        int C = FindBestMatch( nodeIdx, nodeIndices, B );
        if (A == C)
        {
            int nodeIdxA = nodeIdx[A], nodeIdxB = nodeIdx[B];
            TLASNode& nodeA = tlasNode[nodeIdxA];
            TLASNode& nodeB = tlasNode[nodeIdxB];
            TLASNode& newNode = tlasNode[nodesUsed];
            newNode.leftRight = nodeIdxA + (nodeIdxB << 16);
            newNode.aabbMin = fminf( nodeA.aabbMin, nodeB.aabbMin );
            newNode.aabbMax = fmaxf( nodeA.aabbMax, nodeB.aabbMax );
            nodeIdx[A] = nodesUsed++;
            nodeIdx[B] = nodeIdx[nodeIndices - 1];
            B = FindBestMatch( nodeIdx, --nodeIndices, A );
        }
        else A = B, B = C;
    }
    tlasNode[0] = tlasNode[nodeIdx[A]];
}
```

This code closely follows the pseudo-code. When two nodes are paired, a new interior node is created (line 15), which points to existing nodes with indices `nodeIdxA` and `nodeIdxB` (line 16). The AABB of the new interior node is the union of the AABBs of the child nodes (lines 17 and 18). Now that the two nodes are paired, work item A (in the `nodeIdx` array) gets replaced by the index of a newly created TLAS interior node (line 19). Work item B, which is to be removed, gets replaced by the last element in the list (line 20), and the list is shortened by 1 (on line 21, as part of the function call).

And with that, we can suddenly handle far more than a pair of armadillos. Play time!

## Move it

Let’s load a few more armadillos. For starters, 16 of them:

```cpp
void AllTogetherApp::Init()
{
    for (int i = 0; i < 16; i++) bvh[i] = BVH( "assets/armadillo.tri", 30000 );
    tlas = TLAS( bvh, 16 );
}
```

Loading 16 armadillos happens in a flash, but building a BVH for each of them causes a bit of a delay. We want 256 armadillos ultimately, so we’ll need to look into that later.

With 16 objects in memory we need some basic animation to make them move. How about this:

```cpp
void AllTogetherApp::Tick( float deltaTime )
{
    // animate the scene
    static float a[16] = { 0 }, h[16] = { 5, 4, 3, 2, 1, 5, 4, 3 }, s[16] = { 0 };
    for (int i = 0, x = 0; x < 4; x++) for (int y = 0; y < 4; y++, i++)
    {
        mat4 R, T = mat4::Translate( (x - 1.5f) * 2.5f, 0, (y - 1.5f) * 2.5f );
        if ((x + y) & 1) R = mat4::RotateX( a[i] ) * mat4::RotateZ( a[i] );
        else R = mat4::Translate( 0, h[i / 2], 0 );
        if ((a[i] += (((i * 13) & 7) + 2) * 0.005f) > 2 * PI) a[i] -= 2 * PI;
        if ((s[i] -= 0.01f, h[i] += s[i]) < 0) s[i] = 0.2f;
        bvh[i].SetTransform( T * R * mat4::Scale( 0.75f ) );
    }
    ...
```

This super-ugly code makes half of the armadillos bounce, while the other half rotates. It’s all pretty chaotic. The code does however show how flexible things are now: objects are scaled, translated and rotated without any difficulty, using pretty basic matrix math. This will combine quite nicely with a typical scene graph.

Changing the transforms of the BLAS BVHs updates their world space bounds, and so we need to build a new TLAS. We do this each frame:

```cpp
tlas.Build();
```

That’s all! This will invoke the agglomerative builder, which executes in a flash for the 16 armadillos that we have right now. Let’s tilt and move the camera a bit to take it all in:

```cpp
    ...
    float3 p0 = TransformPosition( float3( -1, 1, 2 ), mat4::RotateX( 0.5f ) );
    float3 p1 = TransformPosition( float3( 1, 1, 2 ), mat4::RotateX( 0.5f ) );
    float3 p2 = TransformPosition( float3( -1, -1, 2 ), mat4::RotateX( 0.5f ) );
#pragma omp parallel for schedule(dynamic)
    for (int tile = 0; tile < 6400; tile++)
    {
        int x = tile % 80, y = tile / 80;
        Ray ray;
        ray.O = float3( 0, 4.5f, -8.5f );
        ...
        ```
        
The result is glorious.

![](https://raw.githubusercontent.com/jbikker/ompf2/main/glorious-1.jpg)

## Après Nous le Déluge

It is time for the final step: 256 armadillos. For that we only really need one new ingredient: _instancing_.

Instancing is very commonly used in games:

![](https://raw.githubusercontent.com/jbikker/ompf2/main/lumberyard-meadow-1024x567.jpg)

Here, just a few trees are carbon-copied all over the rolling hills, with a slightly different scale and orientation applied to prevent that we notice the repetition. In a regular 3D engine, instancing helps to reduce memory use and bandwidth between CPU and GPU. In a ray tracer we get essentially the same benefits, plus one more: we can reuse a BLAS if the only difference between two objects can be expressed in a 4×4 matrix: rotation, translation and scale. On a race track that means: one car gets multiplied to form a grid; add a track and you’re done. You could even apply different textures to each car: materials do not affect the BVH, after all.

Let’s make the necessary changes. We start with a `BVHInstance` class, which takes over the matrix transform functionality from the BVH class.

```cpp
// instance of a BVH, with transform and world bounds
class BVHInstance
{
public:
    BVHInstance() = default;
    BVHInstance( BVH* blas ) : bvh( blas ) { SetTransform( mat4() ); }
    void SetTransform( mat4& transform );
    void Intersect( Ray& ray );
private:
    BVH* bvh = 0;
    mat4 invTransform; // inverse transform
public:
    aabb bounds; // in world space
};
```

This leads to a cleaner BVH class: the inverse transform and world space bounds are now gone, as well as the `SetTransform(...)` method. Even the `BVH::Intersect(...)` is simpler now; the ray transform is handled by a short method of `BVHInstance`, which forwards the work, with an already transformed ray, to the BVH.

```cpp
void BVHInstance::Intersect( Ray& ray )
{
    // backup ray and transform original
    Ray backupRay = ray;
    ray.O = TransformPosition( ray.O, invTransform );
    ray.D = TransformVector( ray.D, invTransform );
    ray.rD = float3( 1 / ray.D.x, 1 / ray.D.y, 1 / ray.D.z );
    // trace ray through BVH
    bvh->Intersect( ray );
    // restore ray origin and direction
    backupRay.t = ray.t;
    ray = backupRay;
}
```

From now on, when we would normally process a `BVH`, we now operate on a `BVHInstance`. The TLAS constructor takes a `BVHInstance` array, for instance:

```cpp
TLAS::TLAS( BVHInstance* bvhList, int N )
{
    // copy a pointer to the array of bottom level accstruc instances
    blas = bvhList;
    blasCount = N;
    // allocate TLAS nodes
    tlasNode = (TLASNode*)_aligned_malloc( sizeof( TLASNode ) * 2 * N, 64 );
    nodesUsed = 2;
}
```

That also means that member variable `blas` is now a `BVHInstance*` rather than a `BVH*`. Apart from this, surprisingly few changes are needed; we can simply point to the same BVH now with different transforms, which is exactly what we need. This has a great effect on the scene construction:

```cpp
void AllTogetherApp::Init()
{
    BVH* bvh = new BVH( "assets/armadillo.tri", 30000 );
    for (int i = 0; i < 16; i++)
        bvhInstance[i] = BVHInstance( bvh );
    tlas = TLAS( bvhInstance, 16 );
}
```

A mesh is now loaded once, and a BVH is constructed for it, also once. The only thing that we get 16 of is BVHInstances – but creating these is, well, instantaneous.

Let’s bring in an army of armadillos!

## We’re in the Army Now

Recall the goal of this article: to have 256 armadillos float around in a cubical section of space, rotating and bouncing off the walls. For that, we need some additional data in the `AllTogetherApp` class
```cpp
float3* position, *direction, *orientation;
```

Each of these will become arrays when we initialize the scene.

```cpp
void AllTogetherApp::Init()
{
    ...
    // set up spacy armadillo army
    position = new float3[256];
    direction = new float3[256];
    orientation = new float3[256];
    for( int i = 0; i < 256; i++ )
    {
        position[i] = float3( RandomFloat(), RandomFloat(), RandomFloat() ) - 0.5f;
        position[i] *= 4;
        direction[i] = normalize( position[i] ) * 0.05f;
        orientation[i] = float3( RandomFloat(), RandomFloat(), RandomFloat() ) * 2.5f;
    }
}
```


Finally, we use this data to actually update the transforms of 256 `BVHInstance` objects:

```cpp
void AllTogetherApp::Tick( float deltaTime )
{
    // animate the scene
    for( int i = 0; i < 256; i++ )
    {
        mat4 R = mat4::RotateX( orientation[i].x ) * 
            mat4::RotateY( orientation[i].y ) *
            mat4::RotateZ( orientation[i].z ) * mat4::Scale( 0.2f );
        bvhInstance[i].SetTransform( mat4::Translate( position[i] ) * R );
        position[i] += direction[i], orientation[i] += direction[i];
        if (position[i].x < -3 || position[i].x > 3) direction[i].x *= -1;
        if (position[i].y < -3 || position[i].y > 3) direction[i].y *= -1;
        if (position[i].z < -3 || position[i].z > 3) direction[i].z *= -1;
    }
    ...
    ```
    
And that is all. On my machine, about 8.5 million rays per second are traced through this scene, which now consists of 7.68 million triangles. Updating the TLAS only takes half a millisecond.

## Future Work

From here, the sky is the limit. In terms of BVH maintenance, we can add all kinds of functionality:

- Add refitting for meshes that deform. We can still instance them, complete with animation. 
- Add rebuilding for meshes that undergo more structural changes.
- Move large static meshes by changing their transforms alone.
- Add all this in a single framework that intelligently divides work over frames for an optimal balance between ray tracing speed and BVH maintenance time.

In terms of performance, we’ve only scratched the surface. We can for example trace bundles of rays to greatly speed up the kind of ray distributions we use in these demos, exploiting the fact that rays for nearby pixels tend to travel the same route through a BVH. We can also build a BVH with more than 2 child nodes per level, to reduce the number of traversal steps. This is beneficial for rays that go all over the place, like those for path tracing.

And then there is the actual using of the rays. We’ve done greyscale images so far. Some cleverly aimed rays can yield photo-realistic images. Doing that for animated scenes is the holy grail – and it’s happening in games right now.

But all that is for another day.