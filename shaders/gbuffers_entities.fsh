#version 330 compatibility

uniform sampler2D gtexture;
uniform vec4 entityColor;
uniform float alphaTestRef = 0.1;
uniform int entityId;

in vec2 texcoord;
in vec2 lmcoord;
in vec4 glcolor;
in vec3 worldNormal;
in vec3 worldPos;
in vec3 camPos;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 light;
layout(location = 2) out vec4 normal;

#define enableNightVision
#ifdef enableNightVision
	uniform float nightVision;
#endif

void main()
{
	color = glcolor * texture(gtexture, texcoord);
	color.rgb = pow(color.rgb, vec3(2.2));
	color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
	normal = vec4(worldNormal * 0.5 + 0.5, 1.0);
	light = vec4(lmcoord, 0, 1.0);

	#ifdef enableNightVision
		light.rg += vec2(nightVision * 0.7, nightVision);
	#endif

	if (color.a < alphaTestRef || entityId == 100)
	{
		discard;
	} else if (entityId == 200)
	{
		light = vec4(1.0);
	}

}
