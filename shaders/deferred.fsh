#version 330 compatibility

uniform sampler2D depthtex1;

// Color
uniform sampler2D colortex0;
// Lightmap
uniform sampler2D colortex1;
// Normal
uniform sampler2D colortex2;

uniform bool isEyeInWater;
uniform mat4 gbufferModelView;
uniform vec3 realCamera;

in vec2 texcoord;

/*
const int colortex0Format = RGBA32F;
*/

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

#include "/lib/lighting.glsl"
#include "/lib/position.glsl"

// doing this here cause fuck it why not
const float wetnessHalflife = 300.0; // [1.0 20.0 40.0 60.0 80.0 100.0 120.0 140.0 160.0 180.0 200.0 220.0 240.0 260.0 280.0 300.0 320.0 340.0 360.0 380.0 400.0 420.0 440.0 460.0 480.0 500.0 520.0 540.0 560.0 580.0 600.0 620.0 640.0 660.0 680.0 700.0 720.0 740.0 760.0 780.0 800.0 820.0 840.0 860.0 880.0 900.0 920.0 940.0 960.0 980.0 1000.0]

#define cloudHeightOffset 0 // [-1000 -950 -900 -850 -800 -750 -700 -650 -600 -550 -500 -450 -400 -350 -300 -250 -200 -150 -100 -50 0 50 100 150 200 250 300 350 400 450 500 550 600 650 700 750 800 850 900 950 1000]
#define cloudStrength 1.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0]
#define cloudDistance 4000.0 // [0.0 100.0 200.0 300.0 400.0 500.0 600.0 700.0 800.0 900.0 1000.0 1100.0 1200.0 1300.0 1400.0 1500.0 1600.0 1700.0 1800.0 1900.0 2000.0 2100.0 2200.0 2300.0 2400.0 2500.0 2600.0 2700.0 2800.0 2900.0 3000.0 3100.0 3200.0 3300.0 3400.0 3500.0 3600.0 3700.0 3800.0 3900.0 4000.0 4100.0 4200.0 4300.0 4400.0 4500.0 4600.0 4700.0 4800.0 4900.0 5000.0 5100.0 5200.0 5300.0 5400.0 5500.0 5600.0 5700.0 5800.0 5900.0 6000.0 6100.0 6200.0 6300.0 6400.0 6500.0 6600.0 6700.0 6800.0 6900.0 7000.0 7100.0 7200.0 7300.0 7400.0 7500.0 7600.0 7700.0 7800.0 7900.0 8000.0]
#define customClouds
#ifdef customClouds
	uniform int bedrockLevel;
	uniform int heightLimit;
	uniform sampler2D noisetex0;
	uniform float frameTimeCounter;
	uniform float cloudHeight;
	#include "/lib/blur.glsl"

	const vec3 cloudColorDay = vec3(1.8);
	const vec3 cloudColorNight = vec3(0.03, 0.03, 0.07);
	const vec3 cloudColorRain = vec3(0.5);
#endif



#define clouds(p, r, t) (blur(noisetex0, (p) / r + frameTimeCounter / t, vec2(r)).xyz)

void main()
{

	PositionData position = getPositionData(depthtex1, realCamera);
	WorldData world = getWorldData();

	color = texture(colortex0, texcoord);
	if (position.depth < 1.0)
	{
		vec3 encodedNormal = texture(colortex2, texcoord).rgb;
		vec3 normal = normalize((encodedNormal - 0.5) * 2.0);
		vec2 lightmap = texture(colortex1, texcoord).rg;
		vec3 lightColor = getLightColor(normal, normalize(realCamera - position.world), lightmap, world);
		color.rgb *= lightColor;
	}
	#ifdef customClouds
		else if (!isnan(cloudHeight))
		{
			vec3 playerNormalized = position.player / position.dist;
			float cd = (bedrockLevel + heightLimit) - realCamera.y + cloudHeightOffset;
			if (sign(playerNormalized.y) == sign(cd))
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
				color.rgb = mix(color.rgb, c * cloudStrength, clamp(f, 0.0, 1.0));
			}
		}
	#endif
}
