﻿#define MAX_RIPPLE_COUNT 3

uniform float rippleOriginList[MAX_RIPPLE_COUNT*3];
uniform float rippleDirectionList[MAX_RIPPLE_COUNT*3];

uniform float rippleAliveList[MAX_RIPPLE_COUNT];
uniform float rippleAgeList[MAX_RIPPLE_COUNT];
uniform float rippleRangeList[MAX_RIPPLE_COUNT];

uniform float rippleAngleList[MAX_RIPPLE_COUNT];
uniform float rippleThicknessList[MAX_RIPPLE_COUNT];
// 2D Random
float random (float2 st) {
    return frac(sin(dot(st.xy,
                         float2(12.9898,78.233)))
                 * 43758.5453123);
}

// 2D Noise based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (float2 st) {
    float2 i = floor(st);
    float2 f = frac(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + float2(1.0, 0.0));
    float c = random(i + float2(0.0, 1.0));
    float d = random(i + float2(1.0, 1.0));

    // Smooth Interpolation

    // Cubic Hermine Curve.  Same as SmoothStep()
    float2 u = f*f*(3.0-2.0*f);
    // u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    return lerp(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

float fadeinout(float v, float min, float max, float t1, float t2)
{
    if(min == max) return v;
    v = clamp(v, min, max);
    float per = (v-min) / (max-min);
    if(per <= t1)per = t1 == 0 ? 1 : per / t1;
    else if(per >= t2) per = t2 == 1 ? 0 : (1-per)/(1-t2);
    else per = 1;
    return per;
}
float linstep(float min, float max, float v)
{
    if(min == max) return 0;
    return clamp((v - min) / (max - min), 0.0, 1.0);
}

void CalculateAlpha_float(float3 position, float noise_time, float noise_value, out float alpha, out float position_in_ripple, out float alpha_band, out float alpha_angle)
{
    alpha = 0;
    position_in_ripple = 0;
    alpha_band = 0;
    alpha_angle = 0;

    [unroll]
    for(int i=0; i<MAX_RIPPLE_COUNT; i++)
    {
        if(_DebugMode)
        {
            rippleOriginList[i*3] = rippleOriginList[i*3+1] = rippleOriginList[i*3+2] = 0;
            rippleDirectionList[i*3] = 0; rippleDirectionList[i*3+1] = 0; rippleDirectionList[i*3+2] = 1;

            rippleAliveList[i] = 1;
            rippleAgeList[i] = _TestAge;
            rippleRangeList[i] = _TestRange - _TestThickness * i * 4;

            rippleAngleList[i] = _TestAngle;
            rippleThicknessList[i] = _TestThickness ;

            // rippleAgeList[1] = _TestAge;
            // rippleRangeList[1] = _TestRange-_TestThickness*4;

            // rippleAgeList[2] = _TestAge;
            // rippleRangeList[2] = _TestRange-_TestThickness*8;

            // if(i>0)continue;
        }        
        if(rippleAliveList[i] == 0)
            continue;

        float ripple_alpha = fadeinout(rippleAgeList[i], 0, 1, 0.1, 0.6);

        // calculate ripple's position
        // take the distance that ripple has travelled into account
    
        float ripple_range = rippleRangeList[i];//_RippleSpeed * rippleAgeList[i];
        // ripple_alpha *= fadeinout(ripple_range, 0, _RippleMaxRange, 0, 0.9);
        

        // check if it's inside the range of ripple
        // take the vertex position within the ripple into account
        float3 origin = float3(rippleOriginList[i*3], rippleOriginList[i*3+1], rippleOriginList[i*3+2]);
        float3 direction = normalize(position - origin);
        float dis = distance(position, origin) + noise_value;
        float temp_thickness = rippleThicknessList[i] * smoothstep(0, 0.2, rippleAgeList[i]);   
        // ripple_alpha *= pow(smoothstep(0, 1, fadeinout(dis, ripple_range-temp_thickness*0.5, ripple_range+temp_thickness*0.5, 0.4, 0.6)), _RippleBandGamma);
        ripple_alpha *= pow(smoothstep(0, 1, fadeinout(dis, ripple_range-temp_thickness, ripple_range, 0.4, 0.6)), _RippleBandGamma);
        ripple_alpha *= clamp(noise(float2(direction.x, direction.z) * float2(_NoiseScale, _NoiseScale)) + 0.2, 0.2, 1);


        // check if it's within the angle
        // take the angle between vertex and origin into account 
        float3 ripple_direction = normalize(float3(rippleDirectionList[i*3], rippleDirectionList[i*3+1], rippleDirectionList[i*3+2]));
        float angle = degrees(acos(dot(ripple_direction, direction)));
        ripple_alpha *= 1 - pow(smoothstep(0, rippleAngleList[i]*0.5, angle), _AngleGamma);
        ripple_alpha *= clamp(noise(float2(position.x, position.z) * float2(_NoiseScale, _NoiseScale))+ 0.5, 0.5, 1);

       
        // output alpha
        alpha += ripple_alpha;


        // hard edge
        if(dis > ripple_range-temp_thickness && dis<ripple_range)
        {
            alpha_band += 1;
        }
        else
        {
            alpha_band += 0;
        }
        if(angle < rippleAngleList[i]*0.5)
        {
            alpha_angle += 1;
        }
        else
        {
            alpha_angle += 0;
        }
        // output precentage in ripple
        position_in_ripple = max(position_in_ripple, linstep(ripple_range-temp_thickness, ripple_range, dis));

    }
}

