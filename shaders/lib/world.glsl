#ifndef WORLD_GLSL
#define WORLD_GLSL

	#include "/lib/common.glsl"

	float easeInOutSine(float x)
	{
		float o = cos(3.141592 * x) - 1.0;
		return -o / 2.0;
	}

	uniform int worldTime;
	uniform vec3 shadowLightPosition;
	uniform vec3 sunPosition;
	uniform float wetness;
	struct WorldData
	{
		vec3 higherCBworldDir;
		vec3 sunDir;
		vec3 fogColor;
		vec3 skyColor;
		float sun;
		float moon;
	};

	const vec3 daySkyColor = vec3(0.0, 0.2, 0.961);
	const vec3 nightSkyColor = vec3(0.0, 0.0, 0.01);
	const vec3 rainSkyColor = daySkyColor * 0.3;

	const vec3 dayFogColor = vec3(0.95, 0.9, 1.2) * 0.7;
	const vec3 nightFogColor = vec3(0.008, 0.0, 0.01) * 1.2;
	const vec3 rainFogColor = dayFogColor * 0.8;

	WorldData getWorldData()
	{
		WorldData world;
		vec3 shadowLightVector = shadowLightPosition * 0.01;
		world.higherCBworldDir = mat3(gbufferModelViewInverse) * shadowLightVector;
		shadowLightVector = sunPosition * 0.01;
		world.sunDir = mat3(gbufferModelViewInverse) * shadowLightVector;
		world.sun = sin((worldTime) * 3.14 / 12000.0) / 2.0 + 0.5;
		world.sun = easeInOutSine(world.sun);
		world.moon = 1.0 - world.sun;

		world.skyColor = mix(daySkyColor, rainSkyColor, wetness) * world.sun + nightSkyColor * world.moon;
		world.fogColor = mix(dayFogColor, rainFogColor, wetness) * world.sun + nightFogColor * world.moon;

		return world;
	}

#endif
