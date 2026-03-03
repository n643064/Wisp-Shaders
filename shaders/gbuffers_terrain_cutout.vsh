#version 330 compatibility

in vec2 mc_Entity;
out int blockId;
out vec2 texcoord;
out vec2 lmcoord;
out vec4 glcolor;
out vec3 worldNormal;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;
uniform vec3 realCamera;

#define wavingLeaves
#define wavingLeavesStrength 0.03 // [0.0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2]
#define wavingLeavesSpeed 3.5 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0 4.1 4.2 4.3 4.4 4.5 4.6 4.7 4.8 4.9 5.0 5.1 5.2 5.3 5.4 5.5 5.6 5.7 5.8 5.9 6.0 6.1 6.2 6.3 6.4 6.5 6.6 6.7 6.8 6.9 7.0 7.1 7.2 7.3 7.4 7.5 7.6 7.7 7.8 7.9 8.0 8.1 8.2 8.3 8.4 8.5 8.6 8.7 8.8 8.9 9.0 9.1 9.2 9.3 9.4 9.5 9.6 9.7 9.8 9.9 10.0]
#define weatherAffectsWavingLeaves
void main()
{
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	vec3 view = (gbufferProjectionInverse * gl_Position).xyz;
// 	vec3 playerPos = (gbufferModelViewInverse * vec4(view, 1.0)).xyz;
	vec3 playerPos = mat3(gbufferModelViewInverse) * view;

	vec3 worldPos = playerPos + realCamera;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	lmcoord = lmcoord / (30.0 / 32.0) - (1.0 / 32.0);
	glcolor = gl_Color;
	worldNormal = gl_NormalMatrix * gl_Normal;
	worldNormal = mat3(gbufferModelViewInverse) * normalize(worldNormal);
	blockId = int(mc_Entity.x);
	#ifdef wavingLeaves
		if (blockId == 5)
		{
			vec3 p = vec3(sin(worldPos.x + worldPos.z + worldPos.y + frameTimeCounter * wavingLeavesSpeed)) * wavingLeavesStrength;
			worldPos += p;
			playerPos = worldPos - realCamera;
			view = mat3(gbufferModelView) * playerPos;
			gl_Position = gl_ProjectionMatrix * vec4(view, 1.0);
		}
	#endif
}
