#define repeat(p,r) (mod(p+r/2.,r)-r/2.)

mat2 rot (float a) { float c=cos(a),s=sin(a); return mat2(c,-s,s,c); }

float gyroid (vec3 seed)
{
    return dot(sin(seed),cos(seed.yzx));
}

float fbm (vec3 seed)
{
    float result = 0.;
    float a = .5;
    for (int i = 0; i < 3; ++i) {
        seed += result;
        result += gyroid(seed/a)*a;
        a /= 3.;
    }
    return result;
}

// Dave Hoskins https://www.shadertoy.com/view/4djSRW
float hash13(vec3 p3)
{
    p3  = fract(p3 * .1031);
  p3 += dot(p3, p3.zyx + 31.32);
  return fract((p3.x + p3.y) * p3.z);
}
vec3 hash31(float p)
{
   vec3 p3 = fract(vec3(p) * vec3(.1031, .1030, .0973));
   p3 += dot(p3, p3.yzx+33.33);
   return fract((p3.xxy+p3.yzz)*p3.zyx); 
}
