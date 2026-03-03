#version 330 compatibility

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

void main()
{
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	lmcoord = lmcoord / (30.0 / 32.0) - (1.0 / 32.0);
// 	vec3 viewPos = (gbufferProjectionInverse * gl_Position).xyz;
// 	vec3 playerPos = mat3(gbufferModelViewInverse) * view;

// 	vec3 playerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;

	glcolor = gl_Color;
}
