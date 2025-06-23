With a proper acceleration structure for animated scenes in place, it is time to put it to use. Last time we [laid the groundwork](https://jacco.ompf2.com/2022/05/20/how-to-build-a-bvh-part-7-consolidate/), with a carefully crafted 16-byte hit record for rays, a floating point image buffer (a.k.a. the accumulator) and a restructured application. Everything is now ready for the implementation of a recursive ray tracer, also known as a _Whitted-style_ ray tracer, after the inventor of the algorithm, Turner Whitted.

## Previously, in this series

In the previous episode we ended up with a pretty basic `Trace` function, which contains the code executed for each pixel of the rendered image:

```cpp
float3 WhittedApp::Trace( Ray& ray )
{
    tlas.Intersect( ray );
    Intersection i = ray.hit;
    if (i.t == 1e30f) return float3( 0 );
    return float3( i.u, i.v, 1 - (i.u + i.v) );
}
```


This function returns an RGB color in a floating point vector. In this color representation, RGB={1,1,1} is white. Note that the more common 0..255 color component encoding, although familiar, is not any more ‘natural’ or ‘logical’: the 0..255 range is simply the best we can get when we store each color component in 8 bits. Using floating point numbers, a range of 0..1 makes more sense: e.g., 0 for red means the material does not reflect any red, while 1 means that the material is a perfect reflector for red light. Any value above 1 indicates that the material emits light. A floating point color representation is the format of choice for _physically based rendering_, where reflections cannot exceed 100% of incoming light and emissive colors can be far brighter than what {255,255,255} (i.e., 0xFFFFFF in hexadecimal) in integers can represent.

Getting from the image that we ended up with in article 7 to something that we might consider ‘realistic’ requires some work. In today’s article, we will cover the following ingredients:

1. Per-pixel material colors using barycentric coordinates and a texture map.
2. A proper per-pixel normal at the point of intersection.
3. Basic ‘Lambert’ shading using the smooth normal and a point light source.
4. A skydome, represented by an HDR texture.
5. Recursive reflections using secondary rays.

The primary rays, which we feed into the `Trace` function, as well as secondary rays, will use the BVH functionality we developed earlier. This means that the Whitted-style ray tracer will be able to render animated scenes, in real-time.

## Texture

To keep track of progress, here’s an image of our starting point, taken from the end of article 7:

![](https://raw.githubusercontent.com/jbikker/ompf2/main/tea.jpg)

Step one is to replace the debug visualization of the barycentric coordinates by a proper texture. The texture we will be using for the teapots is this one:

![](https://raw.githubusercontent.com/jbikker/ompf2/main/bricks.jpg)

assets/bricks.png, via richiepanda.ee

This texture was already loaded for the teapot, along with the obj file, in `::Init`:

```cpp
mesh = new Mesh( "assets/teapot.obj", "assets/bricks.png" );
```

The texture is applied to the teapots by reading a color from it for each intersection of a ray and a triangle. We already have all the information to do this: 

- the `Intersection` record contains information about which triangle we intersected;
- the record also contains the barycentric coordinates of the hit point;
- the `triEx` array of the `Mesh` contains the texture coordinates of the triangle vertices;
- the `Mesh` object contains a pointer to the texture.

However, the `Intersection` record does store things rather compact. Let’s unpack the information we need:

```cpp
uint triIdx = i.instPrim & 0xfffff; 
uint instIdx = i.instPrim >> 20;
```

Field `instPrim` stores the instance index and the primitive index. The primitive index can be used to access one triangle, either in the `Mesh::tri` array or in the `Mesh::triEx` array. For texturing, we need `TriEx` data, which holds texture coordinates and vertex normals.

```cpp
TriEx& tri = mesh->triEx[triIdx];
```

The texture can simply be obtained from the mesh. For this article we will stick to a single texture, but in case different instances use different textures, a texture can also be selected based on the instance index.

```cpp
Surface* tex = mesh->texture;
```

Next, we need to calculate a position in the texture, where we will read a single pixel. By the way: pixels from a texture map are commonly referred to as _texels_. The texture coordinate of the ray/triangle intersection point is somewhere between the texture coordinates of the triangle vertices. The exact position is determined using the barycentric coordinates of the intersection test. Be careful when deciphering the following snippet: convention says that both barycentric coordinates and texture coordinates are referred to as u,v… The calculated vector `uv` thus denotes a texture coordinate, while `i.u` and `i.v`hold the barycentric coordinates at the intersection point.

```cpp
float2 uv = i.u * tri.uv1 + i.v * tri.uv2 + (1 - (i.u + i.v)) * tri.uv0;
```

Here, `i.u` and `i.v` are two of the three barycentric coordinates of the intersection point on the triangle. The third barycentric coordinate is `1-(i.u+i.v)`. Using these we obtain a coordinate on the texture, which we store in the 2D vector `uv`. Note that the three vertices of the triangle have been reordered, from 0,1,20,1,2 to 1,2,01,2,0: this has to do with the ordering used in the triangle intersection code.

At this point another convention needs to be mentioned: Texture coordinates are decoupled from texture resolution. The top-left corner of a texture is (0,0), while the bottom-right corner is (1,1) rather than e.g. (511,511) for a 512×512 texture. To actually read data from the bitmap, we thus need to multiply `uv` by the size of the texture. The benefit of this approach is that we can replace textures by images of different dimensions, without consequences for the uv-coordinates.

To complicate things further: although the coordinates typically range from (0,0) to (1,1), we may still encounter coordinates outside this range. This happens for instance when the texture is repeated over the object. E.g., to apply the texture on a single triangle in a 2×2 tile pattern, we would use the range (0,0) to (2,2).

The following code applies the proper scale, and uses a modulo to ensure that tiled textures still yield integer pixel positions within the bitmap:

```cpp
int iu = (int)(uv.x * tex->width) % tex->width;
int iv = (int)(uv.y * tex->height) % tex->height;
uint texel = tex->pixels[iu + iv * tex->width];
```

We’re almost done. Variable `texel` contains an integer color, while the Trace function expects (and returns) floating point colors. Converting from 8-bit integer RGB to 32-bit floating point RGB is done with a small helper function:

```cpp
inline float3 RGB8toRGB32F( uint c )
{
    float s = 1 / 256.0f;
    int r = (c >> 16) & 255;  // extract the red byte
    int g = (c >> 8) & 255;   // extract the green byte
    int b = c & 255;          // extract the blue byte
    return float3( r * s, g * s, b * s );

}
```


We now have a material color, obtained from the texture. This material color, or better: _material reflectivity_, is in physics referred to as _albedo_. For now, we simply return this as the end result of the Trace function, which, in its entirety, now looks as follows:

```cpp
float3 WhittedApp::Trace( Ray& ray )
{
    tlas.Intersect( ray );
    Intersection i = ray.hit;
    if (i.t == 1e30f) return float3( 0 );
    // calculate texture uv based on barycentrics
    uint triIdx = i.instPrim & 0xfffff;
    uint instIdx = i.instPrim >> 20;
    TriEx& tri = mesh->triEx[triIdx];
    Surface* tex = mesh->texture;
    float2 uv = i.u * tri.uv1 + i.v * tri.uv2 + (1 - (i.u + i.v)) * tri.uv0;
    int iu = (int)(uv.x * tex->width) % tex->width;
    int iv = (int)(uv.y * tex->height) % tex->height;
    uint texel = tex->pixels[iu + iv * tex->width];
    float3 albedo = RGB8toRGB32F( texel );
    return albedo;
}
```

The result of this step:

![](https://raw.githubusercontent.com/jbikker/ompf2/main/textured.jpg)

## Normals

Now that textures are working, normals are simple. Or at least, at first they appear to be. The addition is trivial:

```cpp
// calculate the normal for the intersection
float3 N = i.u * tri.N1 + i.v * tri.N2 + (1 - (i.u + i.v)) * tri.N0;
```

We use the same barycentric coordinates, but instead of interpolating between the uv-coordinates of the vertices, we now interpolate between the vertex normals. 

To visualize and inspect the normals we can use a small trick. Normals are vectors with a length of 1; their x, y and z coordinates are guaranteed to be in the range -1..1. We can map this range to colors. For this, we add 1 to x, y and z – this brings them in the range 0..2. Then, we halve the vector, to reduce it to the range 0..1. Three components in the range 0..1: that is a color! The teapots, with their normals, look like this:

![](https://raw.githubusercontent.com/jbikker/ompf2/main/normals.jpg)

At first sight, that’s not bad. The lid of the teapot is green, which is color (0,1,0). That makes sense: the normal of the lid has to be pointing up along the y-axis. Likewise, a red color on the right side of the teapots is to be expected: Red is (1,0,0), which is indeed a vector to the right.

But, when we look closer:

![](https://raw.githubusercontent.com/jbikker/ompf2/main/error.jpg)

There’s seams where we expected smooth normals; the top of the lid looks completely wrong, and, when we look at the spinning teapots: the red side happily rotates to the left and back, instead of staying in place.

To understand the seams, we open the teapot in Visual Studio. Simply drag and drop the teapot.obj file onto the application, and it will be displayed for you in 3D:

![](https://www.cs.uu.nl/docs/vakken/magr/ompf2/vsobj-1024x614.jpg)

It turns out that the artifacts are not caused by the ray tracing code: The model is simply broken, somewhat. This is not uncommon; when you obtain your models for free from the internet, this is sometimes a consequence. Let’s accept the imperfections in this world and move on. 

There is still another problem: the rotating normals.

The rotating normals are caused by the transforms that we apply to the scene objects. Vertex normals are specified in object space; they should thus be transformed with the matrix that we applied to the object. A small extension of the normal calculation code takes care of this:

```cpp
// calculate the normal for the intersection
float3 N = i.u * tri.N1 + i.v * tri.N2 + (1 - (i.u + i.v)) * tri.N0;
N = normalize( TransformVector( N, bvhInstance[instIdx].GetTransform() ) ); 
return (N + float3( 1 )) * 0.5f;
```

The transform that we need is obtained from the `bvhInstance`, indexed by `instIdx`, which we got from the `Intersection` record. Note that the resulting normal must be re-normalized. There are two reasons for this: first of all, the matrix may include a scale, and secondly: interpolation does not guarantee preservation of the vector length. By the way, if the matrix contains a shear or a non-uniform scale, simple re-normalization doesn’t solve the issue. Let’s ignore that for now: It is somewhat uncommon and the solution is quite involved.

With these fixes in place, the normals properly stay in place. The final result of this step:

![](https://raw.githubusercontent.com/jbikker/ompf2/main/normals2.jpg)

## Shading

In the next step we add illumination to the scene. In nature, light transport starts with light sources; without lights everything should thus be black. A simple light source type to start with is a _point light_. A point light has two properties: a _position_ and a _color_. Since we are working with floating point colors, we can now specify pretty bright lights, which is a good thing: the light from any source quickly diminishes with distance. The precise relation is quadratic: at a distance rr, only 1/r21/r2 of the emitted intensity remains.

We start with the definition of the light source:

```cpp
// illuminate the intersection point
float3 lightPos( 3, 10, 2 ); 
float3 lightColor( 150, 150, 120 );
```

To calculate the distance from the light to the point we’re illuminating (the intersection point II), we of course need to know where this point is. The intersection of the ray and the triangle is along the ray, obviously. It is also at a distance `i.t`from the ray origin. The point is thus:

```cpp
float3 I = ray.O + i.t * ray.D;
```

We can now calculate the distance from point II to the light:

```cpp
float3 L = lightPos - I;
float dist = length( L );
```

Apart from distance, we also need to take into account the angle of the triangle towards the light source. For a perfect diffuse material (a.k.a. a Lambert BRDF), the correct attenuation factor is the cosine of the angle between the normal and a normalized vector to the light source. Conveniently, this cosine is calculated using a simple dot product. 

We start the calculation by normalizing the LL vector that we used before to calculate the distance to the light source:

```cpp
L *= 1.0f / dist;
```

A call to a ‘normalize’ function would also have worked, but the multiplication by 1/dist1/dist is faster: we already calculated the distance (which required a square root!), so we can save ourselves another square root. The cosine calculation now becomes:

```cpp
max( 0.0f, dot( N, L ) )
```

The `max( 0, ... )` part clamps negative values to zero; this happens for triangles that do not face the light source. Finally, we put everything together:

```cpp
return albedo * (
    ambient +
    max( 0.0f, dot( N, L ) ) *
    lightColor *
    (1.0f / (dist * dist))
);
```

The formula accounts for the cosine of NN and LL, the color of the light source, the RGB albedo of the material, and the distance attenuation. The final factor, ‘ambient’, is a fixed amount of light we add to account for indirect light. Without this, points in the scene that cannot see the light would be pitch black, which looks unnatural.

The result of this step:

![](https://raw.githubusercontent.com/jbikker/ompf2/main/shaded.jpg)

On my screen, the shading looks a bit off. 

## Skydome

The next ingredient on our list is a _skydome_. Right now, when a ray doesn’t encounter any geometry, the `::Trace` function returns black. We could replace this by a more interesting color, but a much prettier solution is the use of a textured sphere that encloses the entire scene. The texture for this sphere should be an _HDR texture_, with floating point pixel values, so that bright parts of the sky can actually be bright. For this step we will use the following texture, of which an HDR version has been added to the assets folder of the [project on Github](https://github.com/jbikker/bvh_article):

![](https://raw.githubusercontent.com/jbikker/ompf2/main/sky.jpg)

We can load the HDR bitmap in the `::Init` function:

```cpp
// load HDR sky
    int bpp = 0;
    skyPixels = stbi_loadf( "assets/sky_19.hdr", &skyWidth, &skyHeight, &skyBpp, 0 );
    for (int i = 0; i < skyWidth * skyHeight * 3; i++) skyPixels[i] = sqrtf( skyPixels[i] );
    ```
    
This code uses the [stb_image](https://github.com/nothings/stb/blob/master/stb_image.h) image loader library, which is already included with the template used for this series. The `stbi_loadf` function loads an image to float values, and returns a pointer to the result. In the above snippet, the end result is gamma-adjusted (using the square roots) to reduce the HDR range somewhat; this looks nicer for this particular image. 

The loaded texture is a so-called _equirectangular panorama_. To sample this texture we use the ray direction, and the ray direction alone. This is a bit surprising, but when we consider that for all intends and purposes the skydome has a very large (let’s say: infinite) radius, a position inside this dome becomes irrelevant.

The formulas for the u and v coordinates in the panorama are:

```cpp
uint u = skyWidth * atan2f( ray.D.z, ray.D.x ) * INV2PI - 0.5f;
uint v = skyHeight * acosf( ray.D.y ) * INVPI - 0.5f;
```

Here, constant `INVPI` is simply 1/π1/π, and `INV2PI` is 1/2π1/2π. As usual, I try to prevent actual divisions by multiplying by the reciprocal, for performance reasons.

Handling rays that miss geometry, in its entirety:

```cpp
if (i.t == 1e30f)
   {
       // sample sky
       uint u = skyWidth * atan2f( ray.D.z, ray.D.x ) * INV2PI - 0.5f;
       uint v = skyHeight * acosf( ray.D.y ) * INVPI - 0.5f;
       uint skyIdx = u + v * skyWidth;
       return 0.65f * float3( skyPixels[skyIdx * 3], skyPixels[skyIdx * 3 + 1], skyPixels[skyIdx * 3 + 2] );
   }
   ```
   
We need to improve camera movement to appreciate the new functionality. For that, we move the camera setup back to `::Tick`, and tweak it a bit with some matrix magic:

```cpp
// render the scene: multithreaded tiles
    static float angle = 0; angle += 0.01f;
    mat4 M1 = mat4::RotateY( angle ), M2 = M1 * mat4::RotateX( -0.65f );
    // setup screen plane in world space
    p0 = TransformPosition( float3( -1, 1, 1.5f ), M2 );
    p1 = TransformPosition( float3( 1, 1, 1.5f ), M2 );
    p2 = TransformPosition( float3( -1, -1, 1.5f ), M2 );
    float3 camPos = TransformPosition( float3( 0, -2, -8.5f ), M1 );
    ```
    
Don’t forget to store the moving camera position in `ray.O` inside the main loop. With that in place, the output becomes:

![](https://raw.githubusercontent.com/jbikker/ompf2/main/dome.jpg)

## Mirrors

The shading model we have been using so far is the ‘pure diffuse’ BRDF (Bidirectional Reflection Distribution Function, which models the ratio between incoming irradiance and outgoing radiance), also known as the Lambert BRDF. This is simple to model, and, in a Whitted-style ray tracer, non-recursive. Whitted-style ray tracing also can support ‘pure specular’ reflections, which lets us model mirrors, and really shiny teapots.

When a ray with direction DD arrives at a mirror with normal NN, the ray should bounce into a new direction RR, which is calculated as

R=D−2N(D⋅N)R=D−2N(D⋅N)

The origin of the bounced ray is of course the intersection point where the incoming ray hit the triangle.

The light that travels back via the mirror towards the camera is simply the light that the reflected ray finds.

Let’s put this in code:

```cpp
if (mirror)
    {
        // calculate the specular reflection in the intersection point
        Ray secondary;
        secondary.D = ray.D - 2 * N * dot( N, ray.D );
        secondary.O = I + secondary.D * 0.001f;
        secondary.hit.t = 1e30f;
        ```
        
When the primary ray encounters a reflective triangle (we’ll see how we determine this in a minute) we create a new ray, called `secondary`. The secondary ray uses the reflection formula to fill the `D` field. The origin is the intersection point `I`, with a small twist: We don’t want the secondary ray to start exactly _on_ the triangle, because in that case, we may very well find an intersection between the secondary ray and that same triangle, at distance 0. So, we offset the ray slightly: 0.001 in the direction of the reflection. The 0.001 value works well for this particular scene; in general it should be chosen carefully: make it too small and the CPU can’t distinguish it from 0; make it too large and reflections may miss details near the reflective surface.

The purpose of the secondary ray is to find light energy in a new direction. We have a function for that, and it’s called ::Trace. The secondary ray will thus call ::Trace recursively:

```cpp
return Trace( secondary, rayDepth + 1 );
```

There’s a problem with that. If we have multiple shiny teapots, reflections may theoretically bounce forever. We need to put a cap on that. The function definition of Trace is changed to:

```cpp
float3 WhittedApp::Trace( Ray& ray, int rayDepth )
```

The primary ray will call this with a value of 0. Then, just before we recurse, we do a safety check:

```cpp
if (rayDepth >= 10) return float3( 0 );
```

In other words: Don’t bounce more than 10 times. If you do, return black. To see if 10 is a reasonable number, just change ‘black’ to ‘bright purple’ and see if it ever happens.

One final detail remains: How do we determine if a teapot is reflective or not? Let’s hack it: if the `instanceIdx`, multiplied by a small prime number, is odd, we’ll make the teapot reflective, otherwise, we use the Lambert material. Like so: 

```cpp
// shading
    bool mirror = (instIdx * 17) & 1;
    if (mirror)
    {
        // calculate the specular reflection in the intersection point
        Ray secondary;
        secondary.D = ray.D - 2 * N * dot( N, ray.D );
        secondary.O = I + secondary.D * 0.001f;
        secondary.hit.t = 1e30f;
        if (rayDepth >= 10) return float3( 0 );
        return Trace( secondary, rayDepth + 1 );
    }
    else
    {
        // calculate the diffuse reflection in the intersection point
        ...
        ```
        
That completes the implementation of reflections. The result of this step:

![](https://ics.uu.nl/docs/vakken/magr/ompf2/shiny.jpg)

The reflections do emphasize one shortcoming of the ray tracer: There is no anti-aliasing. Luckily, that is easily fixed. We can simply shoot multiple rays through each pixel, and average what they bring back. The multiple rays can go to fixed locations on each pixel, or we can simply pick random positions. Like so:

```cpp
...
    for (int v = 0; v < 8; v++) for (int u = 0; u < 8; u++)
    {
        uint pixelAddress = x * 8 + u + (y * 8 + v) * 640;
        accumulator[pixelAddress] = float3( 0 );
        for( int s = 0; s < 4; s++ )
        {
            // setup a primary ray
            float3 pixelPos = ray.O + p0 +
                (p1 - p0) * ((x * 8 + u + RandomFloat()) / 640.0f) +
                (p2 - p0) * ((y * 8 + v + RandomFloat()) / 640.0f);
            ray.D = normalize( pixelPos - ray.O );
            ray.hit.t = 1e30f; // 1e30f denotes 'no hit'
            accumulator[pixelAddress] += 0.25f * Trace( ray );
        }
    }
    ...
    ```
    
With 16 samples per pixel, this yields a pretty crisp picture, albeit at a terrible framerate. Also notice what this does to the textured teapots!

![](https://raw.githubusercontent.com/jbikker/ompf2/main/crisp.jpg)

## Future Work

Adding anti-aliasing made one thing painfully clear: in terms of performance, we may have work to do. It is definitely possible to improve performance on the CPU, but a real boost will be possible when we switch from CPU to GPU. This is the topic of the next article.

Apart from that, some other things are missing:

- Glass, water and other _dielectrics_
- Shadows!
- Depth of field, soft shadows, motion blur and other _distribution effects_
- Diffuse reflections

Many of these would justify an entirely new series however.