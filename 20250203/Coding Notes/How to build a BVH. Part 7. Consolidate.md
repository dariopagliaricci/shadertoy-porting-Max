With a proper acceleration structure for animated scenes in place, it is time to put it to use. In this article we discuss how to use a BVH for rendering a scene with textured and shaded objects. The concepts introduced in this article will also be useful when we take the BVH to the GPU in article 9.

This is part one of two: shading, including full Whitted-style (recursive) ray tracing is postponed to the next article.

## Preparations & Recap

Until now, all source code was stored in just two files. Now that BVH construction is ‘done’ _(it never is!)_ it is finally time to put the construction and traversal functionality in proper, separate files. On [Github](https://github.com/jbikker) you’ll find that project #7 contains a `bvh.cpp` and `bvh.h` file. The header file contains the class and struct definitions:

- `aabb`, which lets us conveniently maintain axis-aligned bounding boxes, with functionality to initialize them as ‘infinitely inverted boxes’, and functions to grow them using positions or other AABBs.
- `Ray`, which stores everything we need for a ray: an origin and direction, as well as the distance from the origin to the nearest intersection. `Struct Ray` also contains reciprocals of the ray direction, to speed up AABB intersection. The data is ‘unioned’ with `__m128` (‘quadfloat’) values, to facilitate SIMD AABB intersection ([see article #2](https://jacco.ompf2.com/2022/04/18/how-to-build-a-bvh-part-2-faster-rays/)).
- `BVHNode`, which defines a node for a ‘bottom level acceleration structure’ or BLAS, i.e. a BVH over triangles. It is carefully tuned to fit in 32 bytes (discussed at the end of [article #1](https://jacco.ompf2.com/2022/04/13/how-to-build-a-bvh-part-1-basics/)).
- `BVH`, which implements BVH construction and traversal. It ‘owns’ a pool of `BVHNode` objects; the `BVHNode` with index 0 is always the root of the BVH. [Article #3](https://jacco.ompf2.com/2022/04/21/how-to-build-a-bvh-part-3-quick-builds/) discussed efficient binned construction of the BVH.
- `BVHInstance`, which adds a 4×4 matrix transform to the BVH, so we can intersect a single BVH multiple times using transformed rays. This allows for instancing, as well as free ‘rigid motion’. Details in [article 5](https://jacco.ompf2.com/2022/05/07/how-to-build-a-bvh-part-5-tlas-blas/).
- `TLASNode`, which defines a node for the ‘top level acceleration structure’ or TLAS, i.e. a BVH over BVHs. Each leaf node of the TLAS contains exactly one BLAS. Details in [article 5](https://jacco.ompf2.com/2022/05/07/how-to-build-a-bvh-part-5-tlas-blas/) and [article 6](https://jacco.ompf2.com/2022/05/13/how-to-build-a-bvh-part-6-all-together-now/).
- And finally, class `TLAS`, which implements agglomerative clustering of TLASNodes to build the final TLAS structure, with its root node in `tlasNode[0]`.

The .cpp file contains the implementation of these classes and structs, as well as functionality to intersect a ray with a triangle, and with an AABB, with or without SIMD code.

The separation yields a rather brief application in pretty.cpp: just an `::Init` function and a `::Tick` function. That’s nice: we can now focus on code that uses rays in the application files, while the BVH logic is isolated in its own files.

## Textures and Normals

To render scenes with textures and lighting we are going to need more information than just the current set of three vertices per triangle.

![](https://raw.githubusercontent.com/jbikker/ompf2/main/bunnies-2-1024x346.jpg)

Triangle bunny + texture = textured bunny. Texture by Bruno Levy, used with permission.

The first additional piece of information is obviously a _texture_, which is typically specified per mesh. The texture is connected to individual triangles using a uv-coordinate for each vertex. For lighting, we also need triangle _normals_. We can specify one normal for a triangle, or one normal per triangle vertex, which lets us interpolate the normal over the triangle, for a smoothly shaded mesh.

![](https://raw.githubusercontent.com/jbikker/ompf2/main/cow-1024x377.jpg)

Left: per-triangle normals for lighting; right: per-vertex normals, interpolated over the triangles.

Previously, we defined a triangle as follows:

```cpp
// minimalist triangle struct
struct Tri { float3 vertex0, vertex1, vertex2; float3 centroid; };
```

The new data could simply be added to this triangle:

```cpp
// minimalist triangle struct
struct Tri
{
    float3 vertex0, vertex1, vertex2;
    float3 centroid;
    float2 uv0, uv1, uv2;
    float3 N0, N1, N2;
};
```

It turns out that this is not a very good idea. We don’t need the extra data during ray/scene intersection, but it _will_ be read into the caches. Smaller data leaves more room for other data, and therefore we split the triangle data. We keep the original Tri struct, and add another one, just for texturing and shading:

```cpp
// additional triangle data, for texturing and shading
struct TriEx { float2 uv0, uv1, uv2; float3 N0, N1, N2; float dummy; };
```

We will thus store arrays of `Tri` and `TriEx` objects for each mesh, were each element in the `Tri` array has a matching `TriEx` element, with the same index.

Adding the texture also requires some careful consideration. So far we stored triangle data in a BVH object. That doesn’t make sense anymore now that we have texture, normal and uv data: This data has nothing to do with ray/scene intersections and really should be stored elsewhere. The new fundamental geometry class is the Mesh class:

```cpp
class Mesh
{
public:
    Mesh() = default;
    Mesh( const char* objFile, const char* texFile );
    BVH* bvh;
    Tri tri[1024];   // triangle data for intersection
    TriEx triEx[1024];   // triangle data for shading
    int triCount = 0;
    Surface* texture;
};
```

Instead of storing triangles in a BVH, we now assign a BVH to a mesh, which makes more sense. The mesh also stores the new `triEx` array, as well as a texture. To keep things as simple as possible we limit meshes to 1024 triangles; this is a limitation you should of course lift as soon as possible when you adapt this code to your own project. The constructor now takes a basic obj file, as well as a texture file. The Alias Wavefront OBJ file format is chosen here because it supports uv- and normal data, which is precisely what we need.

```cpp
Mesh::Mesh( const char* objFile, const char* texFile )
{
    // bare-bones obj file loader; only supports very basic meshes
    texture = new Surface( texFile );
    float2 UV[1024];
    float3 N[1024], P[1024];
    int UVs = 0, Ns = 0, Ps = 0, a, b, c, d, e, f, g, h, i;
    FILE* file = fopen( objFile, "r" );
    while (!feof( file ))
    {
        char line[256] = { 0 };
        fgets( line, 1023, file );
        if (line == strstr( line, "vt " )) UVs++,
            sscanf( line + 3, "%f %f", &UV[UVs].x, &UV[UVs].y );
        else if (line == strstr( line, "vn " )) Ns++,
            sscanf( line + 3, "%f %f %f", &N[Ns].x, &N[Ns].y, &N[Ns].z );
        else if (line[0] == 'v') Ps++,
            sscanf( line + 2, "%f %f %f", &P[Ps].x, &P[Ps].y, &P[Ps].z );
        if (line[0] != 'f') continue; else
        sscanf( line + 2, "%i/%i/%i %i/%i/%i %i/%i/%i",
            &a, &b, &c, &d, &e, &f, &g, &h, &i );
        tri[triCount].vertex0 = P[a], triEx[triCount].N0 = N[b];
        tri[triCount].vertex1 = P[d], triEx[triCount].N1 = N[e];
        tri[triCount].vertex2 = P[g], triEx[triCount].N2 = N[h];
        triEx[triCount].uv0 = UV[c], triEx[triCount].uv1 = UV[f];
        triEx[triCount++].uv2 = UV[i];
    }
    fclose( file );
    bvh = new BVH( this );
}
```


Again, in a more serious project this needs to be replaced, but for now, it will do.

Moving the triangle data to the mesh has some consequences for the BVH class as well, although the required changes are minor. We store a pointer to the `Mesh` in the `BVH` class, so we can access the data easily. The BVH constructor then becomes:

```cpp
BVH::BVH( Mesh* triMesh )
{
    mesh = triMesh;
    bvhNode = (BVHNode*)_aligned_malloc( sizeof( BVHNode ) * mesh->triCount * 2, 64 );
    triIdx = new uint[mesh->triCount];
    Build();
}
```


Now that we have properly stored the additional data, it is time to actually use it.

## Barycentrics

When a ray hits a triangle, all it stores is the hit distance, if it is smaller than `ray.t`. This was sufficient for the greyscale images we produced so far. However, now that we have textures and normals, we need some additional data:

- The normal at the intersection point
- The texture color at the intersection point

Before we discuss what actually needs to be stored, let’s first see how to obtain an interpolated normal and a texture color in a ray tracer. For that, we need to review the ray/triangle intersection code from article #1:

```cpp
void IntersectTri( Ray& ray, const Tri& tri )
{
    const float3 edge1 = tri.vertex1 - tri.vertex0;
    const float3 edge2 = tri.vertex2 - tri.vertex0;
    const float3 h = cross( ray.D, edge2 );
    const float a = dot( edge1, h );
    if (a > -0.0001f && a < 0.0001f) return; // ray parallel to triangle
    const float f = 1 / a;
    const float3 s = ray.O - tri.vertex0;
    const float u = f * dot( s, h );
    if (u < 0 || u > 1) return;
    const float3 q = cross( s, edge1 );
    const float v = f * dot( ray.D, q );
    if (v < 0 || u + v > 1) return;
    const float t = f * dot( edge2, q );
    if (t > 0.0001f) ray.t = min( ray.t, t );
}
```

On the highlighted lines variables `u` and `v` are calculated and evaluated. Here, u and v are _not_ texture uv-coordinates: they are _barycentric coordinates_, and they are extremely useful. It works like this: Given a triangle with vertices A, B, and C, any point P on the triangle can be reached by combining A, B and C using weights. Let’s call the weights _u_, _v_ and _w_. Now, P=uA+vB+wCP=uA+vB+wC. In a diagram:

![](https://raw.githubusercontent.com/jbikker/ompf2/main/bary.jpg)

At the vertices the weights are pretty simple: e.g., A is just A, so v and w are 0. Between A and B we know that u is decreasing from 1 to 0, while v increases from 0 to 1. We can conclude a few additional things:

1. The sum of u, v and w must be 1 everywhere on the triangle.
2. The weights u, v and w must all be between 0 and 1.
3. Weight w must be 1 – (u + v) and is thus redundant.

The triangle intersection code uses the concept of barycentric coordinates: on line 11, u and w are tested against the valid range, and on line 14, the sum of u and v is tested: this cannot exceed 1.

The triangle intersection code thus gets us u and v, and by extension, w. This is rather useful. The barycentric coordinates do not just let us find points on the triangle, we can also use them to interpolate other values than vertex positions. Given _u_, _v_and _w_, we can combine vertex normals N0N0​, N1N1​ and N2N2​ into interpolated normal NiNi​ and likewise, we can interpolate the uv-coordinates of the vertices to find the uv-coordinate at the point of intersection (be careful not to confuse the barycentric coordinates _u_ and _v_ with texture uv-coordinates – industry standard is sadly to use the letters u and v in both cases…)

Back to the original problem: what do we store at the intersection point? It turns out we need five values:

- t, i.e. the distance along the ray
- the triangle index
- u and v, i.e. the barycentric coordinates on the triangle (not the texture coordinates!).

The fifth value is the index of the instance, which we will need to find the transform. Without this, the normals will be in the untransformed space of the object.

With these five values we can reconstruct everything, regardless of how much data we store per vertex. Perhaps we also stored vertex colors, or a second set of uv-coordinates (e.g. for detail textures or a normal map); all of these can be interpolated at a later time using the stored barycentric coordinates.

Postponing the actual interpolation also helps when a ray intersects multiple triangles along its path through the BVHs. Each time we find a closer intersection, we overwrite earlier results; we need to make sure that storing hit information is efficient.

Let’s define a compact intersection record:

```cpp
// intersection record, carefully tuned to be 16 bytes in size
struct Intersection
{
    float t;		// intersection distance along ray
    float u, v;		// barycentric coordinates of the intersection
    uint instPrim;	// instance index (12 bit) and primitive index (20 bit)
};
```

The five fields are squeezed into 16 bytes here. This will be particularly relevant on the GPU later, where a 16-byte read is a single memory operation, while most other sizes require multiple transactions.

The new hit record is filled with a slightly modified `IntersectTri` function:

```cpp
void IntersectTri( Ray& ray, const Tri& tri, const uint instPrim )
{
    // Moeller-Trumbore ray/triangle intersection algorithm
    ...
    const float t = f * dot( edge2, q );
    if (t > 0.0001f && t < ray.hit.t) 
        ray.hit.t = t, 
        ray.hit.u = u,
        ray.hit.v = v, 
        ray.hit.instPrim = instPrim;
}
```

The `instPrim` value that is passed to `IntersectTri` contains the instance index and the primitive index, packed together in a single 32-bit unsigned int. This value is passed all the way from `BVHInstance::Intersect`, via `BVH::Intersect to IntersectTri`.

## The Other End

Intersecting the ray with the scene now yields quite a bit more info than just an intersection distance. The place to use this data is the application: in this case, in `pretty.cpp` and `pretty.h`.

Let’s make some quick preparations. First thing: the integer pixel buffer. It is pretty much inevitable that our final colors are 32-bit unsigned ints, but for proper rendering, this is not a great choice. Let’s define a proper floating point frame buffer, called the accumulator:

```cpp
accumulator = new float3[640 * 640];
```

This array stores a 3-component vector per pixel, where x, y and z store red, green and blue color components. The floating point storage is more accurate, but more important: it doesn’t clamp intensities at 255.

We write to this buffer by calling a `::Trace` function for each pixel:
```cpp
float3 PrettyApp::Trace( Ray& ray )
{
    tlas.Intersect( ray );
    Intersection i = ray.hit;
    if (i.t == 1e30f) return float3( 0 );
    return float3( i.u, i.v, 1 - (i.u + i.v) );
}
```


This function is called from the multi-threaded tile renderer, with a single ray per pixel. We call this ray the _primary ray_, to distinguish it from the rays that we use for shadows, reflections and refractions.

The rudimentary trace function shown here stores the barycentric coordinates _u_, _v_ and _w_ in the red, green and blue components of the returned color. The result:

![](https://raw.githubusercontent.com/jbikker/ompf2/main/tea.jpg)

Note how the three corners of each triangle indeed turn red, green and blue, while these primary colors smoothly interpolate over the primitive. The data was received!

## Closing Remarks

By now the article got a lot longer than I anticipated; that means that another article needs to be inserted here. Next time we will talk about Whitted-style ray tracing, for which we will use the new intersection information.