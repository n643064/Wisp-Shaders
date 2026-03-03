#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

#include "/lib/world.glsl"

void main()
{
	color = texture(gtexture, texcoord) * glcolor;
	WorldData world = getWorldData();
	float l = (pow(lmcoord.r, 4.0)) + world.sun;
	color.rgb *= clamp(l, 0.0, 1.0);
	color.a *= 0.8;
	if (color.a < alphaTestRef)
	{
		discard;
	}
}
