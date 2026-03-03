#version 330 compatibility

uniform int renderStage;
uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform sampler2D noisetex0;
in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

#include "/lib/world.glsl"
#include "/lib/sky.glsl"

vec3 viewFromScreen(vec3 screen)
{
	vec4 ndc = vec4(screen, 1.0) * 2.0 - 1.0;
	vec4 tmp = gbufferProjectionInverse * ndc;
	return tmp.xyz / tmp.w;
}

void main()
{
	if (renderStage == MC_RENDER_STAGE_STARS) 
	{
		color = glcolor;
		vec3 view = viewFromScreen(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), 1.0));
		vec3 player = mat3(gbufferModelViewInverse) * view;
		color.rgb = pow(texture(noisetex0, player.xz / 100.0).rgb * 2.0, vec3(5.0)) * 4.0;
	} else {
		WorldData world = getWorldData();
		vec3 view = viewFromScreen(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), 1.0));
		vec3 player = mat3(gbufferModelViewInverse) * view;

		color = vec4(getSkyColor(normalize(view), normalize(player), world), 1.0);
	}
}
