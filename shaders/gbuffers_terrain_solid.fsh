#version 330 compatibility

uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;

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


#define rainPuddles
#ifdef rainPuddles
	uniform sampler2D noisetex0;
	uniform float wetness;
	uniform float frameTimeCounter;
	uniform int worldTime;
	const vec3 puddleColorDay = vec3(0.03, 0.03, 0.1);
	const vec3 puddleColorNight = vec3(0.03, 0.01, 0.05);
#endif

#define enableNightVision
#ifdef enableNightVision
	uniform float nightVision;
#endif

void main()
{
	color = glcolor * texture(gtexture, texcoord);
	color.rgb = pow(color.rgb, vec3(2.2));

	normal = vec4(worldNormal * 0.5 + 0.5, 1.0);
	light = vec4(lmcoord, 0, 1.0);
	#ifdef enableNightVision
		light.rg += vec2(nightVision * 0.7, nightVision);
	#endif

	#ifdef rainPuddles
		if (wetness > 0.0)
		{
			vec3 v = texture(noisetex0, worldPos.xz / 2.0).xyz;
			v = texture(noisetex0, (v.xy + worldPos.zx) / 30.0 + frameTimeCounter / 600.0).xyz;
			v = pow(v * 2.5, vec3(7.0));

			vec2 wp = vec2(wetness, step(0.45, v.x)) * vec2(step(0.95, lmcoord.g), max(0.0, worldNormal.y));
			float sun = sin((worldTime) * 3.14 / 12000.0) / 2.0 + 0.5;
			color.rgb += mix(puddleColorNight, puddleColorDay, sun) * wp.x * wp.y;
		}
	#endif

	if (color.a < alphaTestRef)
	{
		discard;
	}
}
