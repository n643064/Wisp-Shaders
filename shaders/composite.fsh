#version 330 compatibility

// Color
uniform sampler2D colortex0;
// Lightmap
uniform sampler2D colortex1;

// WaterData
uniform sampler2D colortex11;
uniform float frameTimeCounter;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform vec3 realCamera;
uniform bool isEyeInWater;
uniform ivec2 eyeBrightnessSmooth;
in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

#include "/lib/position.glsl"
#include "/lib/world.glsl"
#include "/lib/fog.glsl"

const float eyeBrightnessHalflife = 1.5;
uniform float cloudHeight;
void main()
{
	PositionData position = getPositionData(depthtex1, realCamera);
	WorldData world = getWorldData();
	color = texture(colortex0, texcoord);

	if (!isnan(cloudHeight) && position.depth < 1.0)
	{
// 		if (isEyeInWater)
// 		{
//
// 		} else
// 		{
// 			vec4 l = texture(colortex1, texcoord);
			applyFog(color.rgb, position.view, world, float(eyeBrightnessSmooth.y) / 240.0 );
// 		}
	}


// 	vec4 waterData = texture(colortex11, texcoord);


// 	if (waterData.x == 1.0)
// 	{
// 		color = texture(colortex0, texcoord);
// 	} else
// 	{
// 		color = texture(colortex0, texcoord);
// 	}



}
