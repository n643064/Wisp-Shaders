#version 330 compatibility

out vec2 texcoord;
out vec2 lmcoord;
out vec4 glcolor;
out vec3 worldPos;
out vec3 worldNormal;
out vec3 camPos;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform vec3 cameraPosition;

uniform vec3 realCamera;

void main()
{
	camPos = realCamera;
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	vec3 view = (gbufferProjectionInverse * gl_Position).xyz;
// 	vec3 playerPos = (gbufferModelViewInverse * vec4(view, 1.0)).xyz;
	vec3 playerPos = mat3(gbufferModelViewInverse) * view;

	worldPos = playerPos + cameraPosition;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	lmcoord = lmcoord / (30.0 / 32.0) - (1.0 / 32.0);
	glcolor = gl_Color;
	worldNormal = gl_NormalMatrix * gl_Normal;
	worldNormal = mat3(gbufferModelViewInverse) * normalize(worldNormal);

}
