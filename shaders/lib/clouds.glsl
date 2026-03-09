#ifndef CLOUDS_GLSL
#define CLOUDS_GLSL
	uniform int bedrockLevel;
	uniform int heightLimit;

	uniform float cloudHeight;
	#include "/lib/blur.glsl"

	#define cloudHeightOffset 0 // [-1000 -950 -900 -850 -800 -750 -700 -650 -600 -550 -500 -450 -400 -350 -300 -250 -200 -150 -100 -50 0 50 100 150 200 250 300 350 400 450 500 550 600 650 700 750 800 850 900 950 1000]
	#define cloudStrength 1.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0]
	#define cloudDistance 4000.0 // [0.0 100.0 200.0 300.0 400.0 500.0 600.0 700.0 800.0 900.0 1000.0 1100.0 1200.0 1300.0 1400.0 1500.0 1600.0 1700.0 1800.0 1900.0 2000.0 2100.0 2200.0 2300.0 2400.0 2500.0 2600.0 2700.0 2800.0 2900.0 3000.0 3100.0 3200.0 3300.0 3400.0 3500.0 3600.0 3700.0 3800.0 3900.0 4000.0 4100.0 4200.0 4300.0 4400.0 4500.0 4600.0 4700.0 4800.0 4900.0 5000.0 5100.0 5200.0 5300.0 5400.0 5500.0 5600.0 5700.0 5800.0 5900.0 6000.0 6100.0 6200.0 6300.0 6400.0 6500.0 6600.0 6700.0 6800.0 6900.0 7000.0 7100.0 7200.0 7300.0 7400.0 7500.0 7600.0 7700.0 7800.0 7900.0 8000.0]


	const vec3 cloudColorDay = vec3(1.8);
	const vec3 cloudColorNight = vec3(0.03, 0.03, 0.07);
	const vec3 cloudColorRain = vec3(0.5);
	#define clouds(p, r, t) (blur(noisetex0, (p) / r + frameTimeCounter / t, vec2(r)).xyz)

	void applyClouds(inout vec3 color, vec3 playerNormalized, float cd, WorldData world)
	{
		vec3 p = vec3(playerNormalized.xz * (cd / playerNormalized.y), cd).xzy;
		float m = 1.9 - wetness * 0.25;
		vec3 n = clouds(p.xz, 4000.0, 1200.0) * m;
		n = pow(n, vec3(6.0)) * 6.0;

		float f = 1.0 - (n.x + n.y + n.z) / 1.4;
		n = clouds(p.zx + n.yz, 800.0, 100.0) * m;

		f *= n.x * n.z / 2.0;
		vec3 c = mix(cloudColorDay, cloudColorRain, wetness);
		float d = sqrt(p.x*p.x + p.z*p.z);
		f = mix(f, 0.0, clamp(d / cloudDistance, 0.0, 1.0));
		c = mix(cloudColorNight, c, world.sun);
		color = mix(color.rgb, c * cloudStrength, clamp(f, 0.0, 1.0));
	}

#endif
