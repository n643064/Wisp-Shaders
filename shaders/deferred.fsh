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

#define customClouds
#ifdef customClouds
	uniform sampler2D noisetex0;
	uniform float frameTimeCounter;
	#include "/lib/clouds.glsl"
#endif

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
				applyClouds(color.rgb, playerNormalized, cd, world);
			}
		}
	#endif
}
