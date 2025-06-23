
#define R iResolution.xy

// Dave Hoskins https://www.shadertoy.com/view/4djSRW
vec2 hash23(vec3 p3)
{
    p3 = fract(p3 * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+33.33);
    return fract((p3.xx+p3.yz)*p3.zy);
}

float gyroid (vec3 seed)
{
    return dot(sin(seed),cos(seed.yzx));
}

float fbm (vec3 seed)
{
    float result = 0.;
    float a = .5;
    for (int i = 0; i < 3; ++i) {
        seed += result / 2.;
        result += gyroid(seed/a)*a;
        a /= 2.;
    }
    return result;
}

