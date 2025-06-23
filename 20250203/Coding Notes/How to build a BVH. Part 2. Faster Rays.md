
In this second article we explore several approaches to substantially speed up ray traversal. For a static scene, this means faster rendering. However, some of the presented techniques do make BVH construction more costly. How to fix this is a topic for a later article.

## Setting up Shop

In the first article the scene consisted of a list of random triangles. For today’s experiments we will need something fancier. We’ll use a model from the Unity RobotLab scene:

![](https://jacco.ompf2.com/wp-content/uploads/2022/04/backside.jpg)

The model used here ([click](https://github.com/jbikker/bvh_article/raw/main/assets/unity.tri) to download it) consists of exactly 12582 triangles. For the purpose of this article the file was converted to a simplistic format, which can be loaded with just a few lines of code.

```cpp
void FasterRaysApp::Init()
{
    FILE* file = fopen( "assets/unity.tri", "r" );
    float a, b, c, d, e, f, g, h, i;
    for (int t = 0; t < N; t++)
    {
        fscanf( file, "%f %f %f %f %f %f %f %f %f\n",
            &a, &b, &c, &d, &e, &f, &g, &h, &i );
        tri[t].vertex0 = float3( a, b, c );
        tri[t].vertex1 = float3( d, e, f );
        tri[t].vertex2 = float3( g, h, i );
    }
    fclose( file );
    // construct the BVH
    BuildBVH();
}
```


The second change to the code is in the visualization: a bit of depth visualization is obtained by plotting greyscale pixels based on the ray distance.

```cpp
// draw the scene
screen->Clear( 0 );
float3 p0( -2.5f, 0.8f, -0.5f );
float3 p1( -0.5f, 0.8f, -0.5f );
float3 p2( -2.5f, -1.2f, -0.5f );
Ray ray;
for (int y = 0; y < 640; y++) for (int x = 0; x < 640; x++)
{
    ray.O = float3( -1.5f, -0.2f, -2.5f );
    float3 pixelPos = p0 +
        (p1 - p0) * (x / 640.0f) +
        (p2 - p0) * (y / 640.0f);
    ray.D = normalize( pixelPos - ray.O ), ray.t = 1e30f;
    IntersectBVH( ray, rootNodeIdx );
    uint c = 500 - (int)(ray.t * 42);
    if (ray.t < 1e30f) screen->Plot( x, y, c * 0x10101 );
}
```

For this camera view, the scene renders in 300 milliseconds on my machine, which corresponds to about 1.3MRays/s, still on a single core.

![](https://jacco.ompf2.com/wp-content/uploads/2022/04/frontside.jpg)

Something interesting happens when we observe the bunny from the opposite side. When we place the camera at (-1.5f, -0.2f, -2.5) and flip the relative position of the screen plane accordingly by changing -2 to 2 for p0, p1 and p2, we get a different image, but also different performance: suddenly one frame only takes 183 milliseconds, for a ray throughput of more than 2.1MRays/s.

Once we see what causes this, we have the means to always achieve the higher performance level. In this article we will combine this with several other things to greatly improve overall performance.

## Raison d’Être

Before we get to the cause of the puzzling difference between the two camera viewpoints I would like to introduce you to the _Surface Area Heuristic_.

Last time we chose the split plane position and axis in a rather simplistic manner: halfway along the longest axis and perpendicular to that axis, a technique known as the _midpoint split_. It is not hard to come up with scenes where this is not a great idea:

![](https://jacco.ompf2.com/wp-content/uploads/2022/04/badmidpoint.jpg)

A midpoint split in this case yields two large overlapping boxes. A subtle nudge of the plane to the right, so it includes the disc at the bottom of the image, would be much better: the left box would be only slightly bigger, but the box on the right would be tiny. On the other hand, a nudge to the left might also be a good idea: the midpoint split hardly yields a balanced tree, while including the tree discs near the split plane seems far better in that regard.

This raises the question: _what makes a good BVH?_ Should it be balanced, should it quickly isolate empty space, or is there something else?

Let’s take a step back, and think about what the BVH is trying to solve. Without a BVH, we brute-force intersect _N_ triangles. With the BVH, we intersect a small number of triangles, plus a number of bounding boxes. An optimal BVH _minimizes the total number of intersections_. Applied to the local problem of picking a good split plane: since the number of bounding boxes after the split is constant (i.e., two), the optimal split plane is the one that minimizes the number of intersections between a ray and the primitives in both child nodes. _‘A ray’_, without further context, is a _random ray_, unless we specifically construct the BVH for a particular ray – which we don’t.

The word ‘random’ provides an important clue. How many intersections with a random ray need to be evaluated for a bounding box containing _N_ triangles? That depends: if the ray hits the box, the answer is _N_; otherwise it is zero. The cost is thus proportional to _N_, but also proportional to the _probability_ that the ray hits the box.

So, what is the probability of a random ray hitting a random box? Obviously, we can’t calculate this. But we can do something else. Consider these two triangles: 

![](https://jacco.ompf2.com/wp-content/uploads/2022/04/triprob.jpg)

Which of these has a higher probability of being struck by a random ray? Obviously, the larger one. So, although we cannot calculate the probability itself, we do know that it is _proportional to surface area_, and that turns out to be enough. Applying this to boxes, the same principle holds: the chance that a random ray hits a random box is proportional to the surface area of the box. Note: not its volume! This is easy to see when you imagine a box with a height of zero: although it now has a volume of zero, it can still be hit by a ray.

This leads to the formulation of the Surface Area Heuristic:

CSAH=NleftAleft+NrightArightCSAH​=Nleft​Aleft​+Nright​Aright​

In words: the ‘cost’ of a split is proportional to the summed cost of intersecting the two resulting boxes, including the triangles they store. The cost of a box with triangles is proportional to the number or triangles, times the surface area of the box.

## Applying the SAH

The SAH allows us to estimate the cost of a split. But, for what splits do we evaluate this cost? The answer is: _all of them_. There are infinitely many ways to split a bounding box along one axis, and three times more if we consider x, y and z instead of just the longest axis. Fortunately, the _cost function_ is constant between two primitive centroids. This means that we only evaluate it at those locations: 

![](https://jacco.ompf2.com/wp-content/uploads/2022/04/candidates.jpg)

Only after evaluating all of them we know which position (on which axis) is best; this position then replaces the midpoint split position.

We thus replace the midpoint split by a search for the lowest cost. For this, we use candidate split planes through the centroids of all triangles in the node, and for each axis:

```cpp
// determine split axis using SAH
int bestAxis = -1;
float bestPos = 0, bestCost = 1e30f;
for( int axis = 0; axis < 3; axis++ ) for( uint i = 0; i < node.triCount; i++ )
{
    Tri& triangle = tri[triIdx[node.leftFirst + i]];
    float candidatePos = triangle.centroid[axis];
    float cost = EvaluateSAH( node, axis, candidatePos );
    if (cost < bestCost)
        bestPos = candidatePos, bestAxis = axis, bestCost = cost;
}
int axis = bestAxis;
float splitPos = bestPos;
```

The search yields a `bestPos` and a `bestAxis`, which we then use instead of the midpoint split position.

The above code uses function EvaluateSAH to calculate the cost for one potential split. This function needs to determine the bounding boxes that would result from the split, as well as the number of triangles in each of the boxes. Based on this information, the SAH cost function can be evaluated.

```cpp
float EvaluateSAH( BVHNode& node, int axis, float pos )
{
    // determine triangle counts and bounds for this split candidate
    aabb leftBox, rightBox;
    int leftCount = 0, rightCount = 0;
    for( uint i = 0; i < node.triCount; i++ )
    {
        Tri& triangle = tri[triIdx[node.leftFirst + i]];
        if (triangle.centroid[axis] < pos)
        {
            leftCount++;
            leftBox.grow( triangle.vertex0 );
            leftBox.grow( triangle.vertex1 );
            leftBox.grow( triangle.vertex2 );
        }
        else
        {
            rightCount++;
            rightBox.grow( triangle.vertex0 );
            rightBox.grow( triangle.vertex1 );
            rightBox.grow( triangle.vertex2 );
        }
    }
    float cost = leftCount * leftBox.area() + rightCount * rightBox.area();
    return cost > 0 ? cost : 1e30f;
}
```

A new struct `aabb` is used here, which is straightforward but makes the `EvaluateSAH` function a lot more concise:

```cpp
struct aabb
{
    float3 bmin = 1e30f, bmax = -1e30f;
    void grow( float3 p ) { bmin = fminf( bmin, p ), bmax = fmaxf( bmax, p ); }
    float area()
    {
        float3 e = bmax - bmin; // box extent
        return e.x * e.y + e.y * e.z + e.z * e.x;
    }
};
```

There is one thing that remains, and that may come as a bit of a surprise. In the initial version of the Subdivide function, recursion was terminated when a certain triangle count was reached (we used 2). Using the SAH, we can do better. Splitting a node in two new nodes is supposed to reduce the cost function. This is however not always the case. Take the example used in the first article: two triangles may form an axis-aligned quad, which cannot be split into two boxes, unless these two boxes fully overlap. The SAH can be used to easily detect this. We calculate the SAH cost of the parent:
```cpp
float3 e = node.aabbMax - node.aabbMin; // extent of parent
float parentArea = e.x * e.y + e.y * e.z + e.z * e.x;
float parentCost = node.triCount * parentArea;
```

Before splitting, the parent is one box with triangles, so the cost is based on this single box. Now, splitting is supposed to help. If it doesn’t, we should abort the attempt to split.

```cpp
if (bestCost >= parentCost) return;
```

This test replaces the old test.

## Results

Before applying the surface area heuristic, it took 183 milliseconds to render the scene. With the SAH, this is reduced to 128 milliseconds: a 43% speedup.

There is a problem however. Without SAH, the BVH is constructed rapidly: it only takes 2.5 milliseconds on my machine. _With_SAH, this increases to 7.4 _seconds_. The reason is obvious: we simply do a lot more work to determine the split plane position. 

## Order

Back to that weird thing with speed being influenced by camera angle. Consider the following two scenarios:

![](https://jacco.ompf2.com/wp-content/uploads/2022/04/order-1024x643.jpg)

In the left scenario, the ray travels to the south. It intersects the top and bottom node, but depending on the order, it needs to visit both, or only one. This is because an intersection _shortens_ the ray: hitting the first disc along the ray makes the ray short enough to _not_ intersect the bottom node. If on the other hand the ray travelling south visits the _bottom_ node first, it also gets shorter, but not short enough to skip the top node. In the right scenario the ideal order is reversed: this time we will save time if we visit the bottom node first.

It is now clear what happened to the bunny cam: since we visit the nodes in a fixed order, some views are faster than others. We can fix this by visiting the nodes front to back. There are several ways to do this. One way requires a reformulation of the traversal algorithm:

```cpp
void IntersectBVH( Ray& ray )
{
    BVHNode* node = &bvhNode[rootNodeIdx], *stack[64];
    uint stackPtr = 0;
    while (1)
    {
        if (node->isLeaf())
        {
            for (uint i = 0; i < node->triCount; i++)
                IntersectTri( ray, tri[triIdx[node->leftFirst + i]] );
            if (stackPtr == 0) break; else node = stack[--stackPtr];
            continue;
        }
        BVHNode* child1 = &bvhNode[node->leftFirst];
        BVHNode* child2 = &bvhNode[node->leftFirst + 1];
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

The traversal looks quite different from what we had before. For starters, the code is no longer recursive. An infinite loop is used instead, and whenever two child nodes require a visit, one of them is pushed on a small stack. The loop completes when we try to pop from an empty stack.

Secondly, the test to check if we intersect a node is removed; this time we check if the child nodes intersect the ray. The answer from the `IntersectAABB` function is also no longer a boolean, but a float: 1e30f denotes ‘miss’, while any other value is a hit at the reported distance:

```cpp
float IntersectAABB( const Ray& ray, const float3 bmin, const float3 bmax )
{
    float tx1 = (bmin.x - ray.O.x) / ray.D.x, tx2 = (bmax.x - ray.O.x) / ray.D.x;
    float tmin = min( tx1, tx2 ), tmax = max( tx1, tx2 );
    float ty1 = (bmin.y - ray.O.y) / ray.D.y, ty2 = (bmax.y - ray.O.y) / ray.D.y;
    tmin = max( tmin, min( ty1, ty2 ) ), tmax = min( tmax, max( ty1, ty2 ) );
    float tz1 = (bmin.z - ray.O.z) / ray.D.z, tz2 = (bmax.z - ray.O.z) / ray.D.z;
    tmin = max( tmin, min( tz1, tz2 ) ), tmax = min( tmax, max( tz1, tz2 ) );
    if (tmax >= tmin && tmin < ray.t && tmax > 0) return tmin; else return 1e30f;
}
```

Using the distances to both child nodes, we can sort them: now, if the nearest child is at distance 1e30f, we know we must have missed them both, in which case we proceed with a node from the stack. Otherwise, we proceed with the nearest child. If the far child also requires visitation, we push this one on the stack.

The resulting traversal is faster for both camera views. The front-side view drops from 128 to 107 milliseconds. The back-side view improves from 300 to 91 milliseconds: more than 3 times faster than without ordering.

## Low Hanging Fruit

Let’s finish this article with some quick and dirty optimizations. For this, we visit the `IntersectAABB` function once more. It contains no less than six divisions, which are notoriously expensive for processors. In this case, they are easy to get rid of.

A division by _x_ can be replaced by a multiplication by _1/x_. In this case, that doesn’t look particularly useful, because _1/x_itself contains a division. However, one ray gets intersected with many boxes; that means that the cost of calculating _1/ray.D.x_yz can be cached. This requires a modification to the ray struct:

```cpp
struct Ray { float3 O, D, rD; float t = 1e30f; };
```

Member variable rD will contain the reciprocals of the direction components, which we can set right after constructing the ray:

```cpp 
ray.rD = float3( 1 / ray.D.x, 1 / ray.D.y, 1 / ray.D.z ); 
```

From here on, `IntersectAABB` operates without divisions:

```cpp
float IntersectAABB( const Ray& ray, const float3 bmin, const float3 bmax )
{
    float tx1 = (bmin.x-ray.O.x) * ray.rD.x, tx2 = (bmax.x-ray.O.x) * ray.rD.x;
    float tmin = min( tx1, tx2 ), tmax = max( tx1, tx2 );
    float ty1 = (bmin.y-ray.O.y) * ray.rD.y, ty2 = (bmax.y-ray.O.y) * ray.rD.y;
    tmin = max( tmin, min( ty1, ty2 ) ), tmax = min( tmax, max( ty1, ty2 ) );
    float tz1 = (bmin.z-ray.O.z) * ray.rD.z, tz2 = (bmax.z-ray.O.z) * ray.rD.z;
    tmin = max( tmin, min( tz1, tz2 ) ), tmax = min( tmax, max( tz1, tz2 ) );
    if (tmax >= tmin && tmin < ray.t && tmax > 0) return tmin; else return 1e30f;
}
```


On my machine this optimization has limited effect, which indicates that the performance problem may lie elsewhere. Perhaps the traversal code is memory bound (which causes the divisions to be hidden behind memory latencies) or perhaps we suffer from branch mispredictions in the conditional code in `IntersectAABB`. A definitive diagnosis requires a proper profiling session with a specialized tool such as Intel’s VTune. Instead of that, I am going to propose two optimizations: one that aims to improve cache utilization, and one that reduces the amount of conditional code.

**1. Improving data locality:** To make better use of the caches, we should ensure that data that we use is similar to data we have recently seen. This is known as _temporal data locality_. In a ray tracer this can be achieved by rendering the image in tiles. The pixels in a tile of e.g. 4×4 pixels often find the same triangles, typically after traversing the same BVH nodes. For this, we change the pixel plotting loops as follows:

```cpp
for (int y = 0; y < 640; y+=4) for (int x = 0; x < 640; x+=4)
{
    for( int v = 0; v < 4; v++ ) for( int u = 0; u < 4; u++ )
    {
        // ray.O = float3( -1.5f, -0.2f, -2.5f );
        ray.O = float3( -1.5f, 0, 2.5f );
        float3 pixelPos = ray.O + p0 +
            (p1 - p0) * ((x + u) / 640.0f) +
            (p2 - p0) * ((y + v) / 640.0f);
        ray.D = normalize( pixelPos - ray.O ), ray.t = 1e30f;
        ray.rD = float3( 1 / ray.D.x, 1 / ray.D.y, 1 / ray.D.z );
        IntersectBVH( ray );
        uint c = 500 - (int)(ray.t * 42);
        if (ray.t < 1e30f) screen->Plot( x + u, y + v, c * 0x10101 );
    }
}
```

**2. Reducing conditional code:** We can change `IntersectAABB` to a version that is mostly devoid of conditional code. This version does however require an Intel compatible CPU, so the following is very platform dependent.

We start with a modification of the BVHNode:
```cpp
struct BVHNode
{
    union
    {
        struct { float3 aabbMin; uint leftFirst; };
        __m128 aabbMin4;
    };
    union
    {
        struct { float3 aabbMax; uint triCount; };
        __m128 aabbMax4;
    };
    bool isLeaf() { return triCount > 0; }
};
```

This rather horrible data structure uses an unnamed union to overlap the two `float3` + `uint` structs with a `__m128`(pronounced as ‘quadfloat’) value, which is a 128-bit vector variable that stores four floats. The `__m128` data type is supported in hardware on pretty much any processor. The union lets us access the original data without changes. At the same time, we can now read the bounding box information into two SSE registers, which lets us use a rather cryptic piece of intersection logic. Before we get to that, we need to make a similar change to the ray struct:
```cpp
struct Ray
{
    Ray() { O4 = D4 = rD4 = _mm_set1_ps( 1 ); }
    union { struct { float3 O; float dummy1; }; __m128 O4; };
    union { struct { float3 D; float dummy2; }; __m128 D4; };
    union { struct { float3 rD; float dummy3; }; __m128 rD4; };
    float t = 1e30f;
};
```

The constructor makes sure that the three dummy values that pad the 12-byte float3 values to 16 bytes are initialized to valid floats. The SIMD AABB intersection code now becomes:

```cpp
float IntersectAABB_SSE( const Ray& ray, const __m128 bmin4, const __m128 bmax4 )
{
    static __m128 mask4 = _mm_cmpeq_ps(_mm_setzero_ps(),_mm_set_ps(1,0,0,0));
    __m128 t1 = _mm_mul_ps(_mm_sub_ps(_mm_and_ps(bmin4,mask4),ray.O4),ray.rD4 );
    __m128 t2 = _mm_mul_ps(_mm_sub_ps(_mm_and_ps(bmax4,mask4),ray.O4),ray.rD4 );
    __m128 vmax4 = _mm_max_ps(t1,t2), vmin4 = _mm_min_ps(t1,t2);
    float tmax = min(vmax4.m128_f32[0],min(vmax4.m128_f32[1],vmax4.m128_f32[2]));
    float tmin = max(vmin4.m128_f32[0],max(vmin4.m128_f32[1],vmin4.m128_f32[2]));
    if (tmax >= tmin && tmin < ray.t && tmax > 0) return tmin; else return 1e30f;
}
```

On my Ryzen processor this yields a modest speed boost compared to the original code. That same Ryzen also made clear to me that doing calculations on numbers that are not floats (in this case: the fourth component in `aabbMin4` and `aabbMax4`, which really are ints) is exceedingly slow. The SSE intersection code counters this by masking these values out.

With the improved data locality and SIMD code we reach the final performance level for this article. For the backside view we end up with 86ms per frame, which means we are blasting the scene with 4.5MRays/s. The frontside view is a little bit slower at 103ms, but that is still 3.8MRays/s, on a single core.

If you are interested in trying out multi-core performance: OpenMP lets you start with this with relative ease. You will have to play a bit with the tile size to optimize performance. Also make sure to use the dynamic scheduler: each tile has a different workload. As a target, know that good parallel ray tracing should scale linearly in the number of cores, although OpenMP alone may not completely get you there.

## Closing Remarks

The next article in this series discusses [binned BVH building for rapid construction](https://jacco.ompf2.com/2022/04/21/how-to-build-a-bvh-part-3-quick-builds/). Check it out now.
