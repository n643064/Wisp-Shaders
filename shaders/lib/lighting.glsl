#ifndef LIGHTING_GLSL
#define LIGHTING_GLSL

    #define blockLightAttenuation 3.0 // [0.0 0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5 8.0 8.5 9.0 9.5 10.0 10.5 11.0 11.5 12.0 12.5 13.0 13.5 14.0 14.5 15.0 15.5 16.0 16.5 17.0 17.5 18.0 18.5 19.0 19.5, 20.0]
    #define celestialLightAttenuation 6.0 // [0.0 0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5 8.0 8.5 9.0 9.5 10.0 10.5 11.0 11.5 12.0 12.5 13.0 13.5 14.0 14.5 15.0 15.5 16.0 16.5 17.0 17.5 18.0 18.5 19.0 19.5, 20.0]
    #define celestialLightStrength 1.3 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]
    #define skyLightStrength 0.8 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]
    #define blockLightStrength 1.0 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]
    #define ambientLightAmount 0.01

    #include "/lib/world.glsl"

    const vec3 skyLightColor = vec3(0.7, 0.7, 1.0);
    const vec3 sunLightColor = vec3(1.0, 0.8, 0.4);
    const vec3 moonLightColor = vec3(0.27, 0.22, 0.8) * 0.2;
    const vec3 ambientLightColor = vec3(0.03, 0.25, 0.54);
    const vec3 blockLightColor = vec3(1.0, 0.85, 0.74);
    const vec3 blockLightEdgeColor = vec3(1.7, 0.2, 0.8);

    const float ambientOcclusionLevel = 1.0;

    #define PI 3.1415
    #define hPI 1.5707

    float easeSunStrength(float x)
    {
        return sin(x * hPI) / 1.3;
    }


    vec3 getLightColor(vec3 normal, vec3 viewVector, vec2 lightmap, WorldData world)
    {
        float d = clamp(dot(world.higherCBworldDir, normal), 0, 1.0);

        #define lightWrapping
        #ifdef lightWrapping
            d = max(0, (d + 1.0) / 2.0);
        #endif
//         d = pow(d, 1.1);

        float c = clamp(pow(lightmap.g, celestialLightAttenuation), 0.05, 1.0);
        float b = pow(lightmap.r, blockLightAttenuation);

        vec3 celestialLight = (sunLightColor * easeSunStrength(world.sun) + moonLightColor * world.moon);
        celestialLight *= d * c * celestialLightStrength;

        vec3 skyLight = skyLightColor * world.sun * skyLightStrength * c;

        vec3 blockLight = mix(blockLightEdgeColor, blockLightColor, lightmap.r) * b * blockLightStrength;

        vec3 color = ambientLightColor * ambientLightAmount + 0.001 + celestialLight + skyLight + blockLight;

        return color;
    }


#endif
