#ifndef SKY_GLSL
#define SKY_GLSL

    uniform float far;

    #include "/lib/world.glsl"
    
    #define skyColorTransitionWidth 0.02 // [0.02 0.04 0.06 0.08 0.1 0.12 0.14 0.16 0.18 0.2 0.22 0.24 0.26 0.28 0.3 0.32 0.34 0.36 0.38 0.4 0.42 0.44 0.46 0.48 0.5]
    #define cbChangeColor
    const vec3 transitionColor = vec3(1.8, 0.4, 0.2);

    float bell(float x, float w)
    {
        float x2 = x*x + w;
        return w / x2;
    }

    vec3 getSkyColor(vec3 viewPosNormalized, vec3 playerPosNormalized, WorldData world)
    {
        float f = dot(viewPosNormalized, gbufferModelView[1].xyz);
        float upDot = bell(clamp(f, 0.0, 1.0), skyColorTransitionWidth);
        vec3 color = mix(world.skyColor, world.fogColor, upDot);

        #ifdef cbChangeColor
            float d = bell(abs(world.sun - world.moon), 0.005);
            float cbDot = bell(max(0, 1.5 + dot(-playerPosNormalized, world.higherCBworldDir)), 1.2);
            vec3 tColor = transitionColor * cbDot * upDot;
            color = mix(color, tColor, d);
        #endif
        return color;
    }
#endif
