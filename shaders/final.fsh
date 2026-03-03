#version 330 compatibility

// Color
uniform sampler2D colortex0;
// Lightmap
uniform sampler2D colortex1;
// Normal
uniform sampler2D colortex2;

uniform sampler2D depthtex0;

uniform float blindness;
uniform float darknessFactor;
uniform float darknessLightFactor;
uniform vec3 realCamera;

/*
const int colortex0Format = RGBA32F;
*/

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

#include "/lib/lighting.glsl"
#include "/lib/position.glsl"

void main() 
{
	PositionData position = getPositionData(depthtex0, realCamera);
	WorldData world = getWorldData();

	color = texture(colortex0, texcoord);
	
	#define blindnessEffects
	#ifdef blindnessEffects
		color.rgb /= (1 + blindness * 5 + darknessFactor - darknessLightFactor);
	#endif

	color.rgb = pow(color.rgb, vec3(1.0 / 2.2));
}
