#version 330 compatibility

uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;

in vec2 texcoord;
in vec2 lmcoord;
in vec4 glcolor;
in vec3 worldNormal;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 light;
layout(location = 2) out vec4 normal;

void main()
{
	color = glcolor * texture(gtexture, texcoord);
	color.rgb = pow(color.rgb, vec3(2.2));

	normal = vec4(worldNormal * 0.5 + 0.5, 1.0);
	light = vec4(lmcoord, 0, 1.0);

	if (color.a < alphaTestRef)
	{
		discard;
	}

}
