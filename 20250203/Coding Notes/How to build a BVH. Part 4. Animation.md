
In this fourth article we make a start with rendering animated scenes. For a single mesh we have two options: rebuilding and _refitting_. Once we have these at our disposal we can go for the Holy Grail: animating scenes with multiple objects.
## Needful Things

As usual, we’ll start with some modifications to the code to facilitate the introduction of some new concepts. We will need a new model, for which I picked London’s Westminster clock tower from [Sketchfab](https://sketchfab.com/):

![](https://raw.githubusercontent.com/jbikker/ompf2/main/bigben.jpg)

Just the tower though. Without textures. In greyscale. Sorry.

The 3D rendition of the tower has 20944 triangles, which will tax the BVH builder a bit more than the Unity vehicle. Rendering the slender object on the other hand is faster, as it occupies less pixels. This lets us focus on BVH maintenance for this article without worrying too much about rendering performance. Speaking of rendering performance: here is a new `Tick` function, with an adjusted camera and somewhat fine-tuned OpenMP multithreading:

```cpp
{
    float3 p0( -1, 1, 2 ), p1( 1, 1, 2 ), p2( -1, -1, 2 );
    #pragma omp parallel for schedule(dynamic)
    for (int tile = 0; tile < 6400; tile++)
    {
        int x = tile % 80, y = tile / 80;
        Ray ray;
        ray.O = float3( 0, 3.5f, -4.5f );
        for (int v = 0; v < 8; v++) for (int u = 0; u < 8; u++)
        {
            float3 pixelPos = ray.O + p0 + 
                (p1 - p0) * ((x * 8 + u) / 640.0f) + 
                (p2 - p0) * ((y * 8 + v) / 640.0f);
            ray.D = normalize( pixelPos - ray.O ), ray.t = 1e30f;
            ray.rD = float3( 1 / ray.D.x, 1 / ray.D.y, 1 / ray.D.z );
            IntersectBVH( ray );
            uint c = ray.t < 1e30f ? (255 - (int)((ray.t - 4) * 180)) : 0;
            screen->Plot( x * 8 + u, y * 8 + v, c * 0x10101 );
        }
    }
}
```

On my machine, this renders one frame in less than 4 milliseconds. Building the BVH using the 8-plane binned builder takes about 30 milliseconds. The rendered image looks like this:

![](https://raw.githubusercontent.com/jbikker/ompf2/main/tower.jpg)

Not as shiny as the photo of the original, but it will have to do. Time to add some movement!

## Being Flexible

Let’s add a bit of a swing to Big Ben’s tower:

```cpp
void Animate()
{
    static float r = 0;
    if ((r += 0.05f) > 2 * PI) r -= 2 * PI;
    float a = sinf( r ) * 0.5f;
    for( int i = 0; i < N; i++ ) for( int j = 0; j < 3; j++ )
    {
        float3 o = (&original[i].vertex0)[j];
        float s = a * (o.y - 0.2f) * 0.2f;
        float x = o.x * cosf( s ) - o.y * sinf( s );
        float y = o.x * sinf( s ) + o.y * cosf( s );
        (&tri[i].vertex0)[j] = float3( x, y, o.z );
    }
}
```

This code applies a 2D rotation to each triangle vertex, with a sine-wave angle scaled by the y-position of the vertex. Whatever; the result looks like a stiff breeze is bothering the tower:

![](https://raw.githubusercontent.com/jbikker/ompf2/main/swing.jpg)

Two frames of the animation sequence.

The animation code requires a copy of the unmodified triangles. So, we create room for two copies of the triangle set
```cpp
Tri tri[N], original[N];
```

Array `tri` contains the input for the BVH builder; array `original` stores the unmodified data. The ::Init function now thus reads to the `original` array:

```cpp
void AnimationApp::Init()
{
    FILE* file = fopen( "assets/bigben.tri", "r" );
    for (int t = 0; t < N; t++) fscanf( file, "%f %f %f %f %f %f %f %f %f\n",
        &original[t].vertex0.x, &original[t].vertex0.y, &original[t].vertex0.z,
        &original[t].vertex1.x, &original[t].vertex1.y, &original[t].vertex1.z,
        &original[t].vertex2.x, &original[t].vertex2.y, &original[t].vertex2.z );
}
```

Since we are now changing the mesh each frame, we should build the BVH each frame as well. This requires a few small changes to the `BuildBVH()` function. First of all, it should not allocate the `bvhNode` array each time we build a BVH, so this needs to be allocated elsewhere. Second, we need to reset the pointer to the next free node in the `bvhNode` array, by resetting `nodesUsed` to 2: Recall that `bvhNode[0]` is the BVH root node, and `bvhNode[1]` is skipped to ensure that subsequent pairs of nodes reside in the same cache line.

With these changes made, we can call the new `Animate()` function and the updated `BuildBVH()` function once per frame, in the `::Tick` function, to obtain the desired ray traced animated scene.

## If It Fits

The animated flexible Big Ben is now being ray traced in real-time – if your system is fast enough. On my machine I get almost 30fps. If the total frame time, about 30ms is spent on building the BVH each frame, while rendering takes 4 milliseconds.

It seems like we may have a problem for a more complex scene, or a mesh that covers more pixels. We may have to come up with a smarter solution to stay real-time under those circumstances.

Let’s take a look at a very simple animation, one in which the clock tower takes off for a trip to the moon:

![](https://raw.githubusercontent.com/jbikker/ompf2/main/takeoff-1.jpg)

Boldly going where no Big Ben has gone before.

The three frames have something in common: their BVH. For the construction of each of the three BVHs, _exactly the same_decisions are made. We will have the same number of nodes and the same number of triangles in each leaf node. The only difference is in the _bounds_ that we store in every node: these will have a vertical offset. 

Obviously there is a better and faster way to handle this type of animation. Instead of moving the missile _up_, we can move the camera _down_ to obtain the same result – without ever rebuilding the BVH. But what if the animation is a little different?

![](https://raw.githubusercontent.com/jbikker/ompf2/main/threeframes.jpg)

This time moving the camera isn’t going to work. And we can also not simply assume that the BVHs differ only in their bounds. They _are_ going to be rather similar though. What if we _would_ in fact use the same tree, with updated bounds only? It certainly would save a lot of time in construction work. 

The technique where we reuse a BVH for an animated mesh is called _refitting_. The process starts at the leaf nodes, which contain the (now changed) triangles. Each leaf node gets an updated bounding box. The update may have consequences for the parent nodes of the leaf nodes, so we adjust their bounds as well, by making them tightly fit their child nodes. We proceed this way until we reach the root of the tree.

This sounds like a recursive process, but in practice, a simpler approach can be used.

When we created the BVH, we used node 0 for the root. After that, every child node got allocated after its parent; we thus know that the index of a child is _always_ greater than the index of its parent. We can exploit this by visiting all nodes starting at the end of the list, working our way back to the first element. This reverse order guarantees that we never visit an interior node with outdated child nodes.

With this trick, the refit functionality becomes rather simple:

```cpp
void RefitBVH()
{
    for (int i = nodesUsed - 1; i >= 0; i--) if (i != 1)
    { 
        BVHNode& node = bvhNode[i];
        if (node.isLeaf())  
        {
            // leaf node: adjust bounds to contained triangles
            UpdateNodeBounds( i );
            continue;
        }
        // interior node: adjust bounds to child node bounds
        BVHNode& leftChild = bvhNode[node.leftFirst];
        BVHNode& rightChild = bvhNode[node.leftFirst + 1];
        node.aabbMin = fminf( leftChild.aabbMin, rightChild.aabbMin );
        node.aabbMax = fmaxf( leftChild.aabbMax, rightChild.aabbMax );
    }
}
```

In words: we visit all the allocated nodes, starting at the last and skipping node 1. If the node is a leaf, we recalculate its bounds using the triangles it contains. For interior nodes, we adjust the bounds so they enclose the two child nodes. The whole procedure is pretty simple, and completes in half a millisecond. That means that the flexible tower now gets updated _and_ rendered in less than 5 milliseconds: we are actually ray tracing a dynamic scene at 200fps, unoptimized and all.

## Bad News

Based on the findings so far it would seem that BVH refitting is a golden bullet to handle all animation. This is sadly not the case. For starters, refitting requires that animation frames have the same number of triangles. It also requires that the structure of the animation frames is roughly equal. Consider the following situation:

![](https://raw.githubusercontent.com/jbikker/ompf2/main/smallchange-1024x433.jpg)

Here, the large triangle moved a bit, invalidating the right bounding box. This is not a big deal; refitting is quite effective here:

- we adjust the right box to tightly fit the new set of primitives
- we adjust the root box: it becomes a bit smaller at the right side and the bottom.

But now consider a different situation.

![](https://raw.githubusercontent.com/jbikker/ompf2/main/bigchange-1024x433.jpg)

This time, one of the small objects from the top-left node moved all the way to the bottom right of the scene. If we update the top-left box to include the moved object, the resulting box will be massive; it will almost entirely overlap the right box. Quite obviously the resulting tree is rather bad. A much better choice would be to include the moved object in the right node – but that’s not what refitting does.

In general, refitting is applied when we have subtle animation: trees waving in the wind, objects changing position, perhaps in some cases a walking character. In those cases, we get the BVH update almost for free, often at the expense of (some) tree quality. In other cases, a rebuild will be the better option. We can also combine rebuilding and refitting: in that case, we refit some subsequent frames, and after a few refits, we rebuild, to ensure that the BVH doesn’t deteriorate too much. A well-designed ray tracing engine will strive to rebuild a few meshes per frame, while refitting the others.

## On Track

Finally, have a look at this scene from a racing game:

![](https://raw.githubusercontent.com/jbikker/ompf2/main/racinggame.jpg)

How should we build a BVH for this animation? We have a few different situations:

- The track is large and static: we should build a high-quality BVH once for this.
- The race cars move, but do not deform; so they could be refitted.
- The audience next to the track goes through a simple animation sequence: we could precalculate a small set of BVHs for this.

The challenge is of course in the combination. How to handle that is the topic of the [next article](https://jacco.ompf2.com/2022/05/07/how-to-build-a-bvh-part-5-tlas-blas/).