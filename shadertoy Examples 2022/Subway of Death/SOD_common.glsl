#define PI 3.1415926535
#define saturate(x) clamp(x, 0.0, 1.0)

float circle( vec2 position, float radius)
{
    return length(position) - radius;
}

float box(vec2 p,vec2 s)
{
    p=abs(p)-s;
    return max(p.x,p.y);
}

vec2 path(float z, float time)
{
    z *= 0.25;
    vec4 s0 = sin(vec4(z*0.5, z*0.3 + 1.5, z*0.4 + 0.5, z*0.6 + 2.0));
    vec4 s1 = vec4(z) + s0;
    vec4 s = sin(vec4(s1.x, s1.y+2.0, s1.z+0.5, s1.w+3.0) - vec4(1.6, 1.7, 1.3, 1.5));
    
    return vec2(s.x + s.y, s.z + s.w);
}

//Distance Field functions by iq :
//https://iquilezles.org/articles/distfunctions
vec4 opRep( vec4 p, vec4 c )
{
    return mod(p,c)-0.5*c;
}

float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

