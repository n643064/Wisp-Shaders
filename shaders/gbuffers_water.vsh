#version 330 compatibility

// in vec2 mc_Entity;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 worldNormal;
out vec3 worldPos;
out vec3 playerPos;
out vec3 camPos;
out vec3 viewPos;
flat out int blockId;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform vec3 realCamera;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;
uniform float wetness;
in vec2 mc_Entity;

float getWaveHeight(vec3 p)
{
	float w = sin(p.x / 2.0 + frameTimeCounter * (1.0 + wetness * 0.7)) * 0.1;
	w += sin(p.z / 4.0 + frameTimeCounter * (1.0 + wetness * 0.7)) * 0.05;
	return w;
}

void main()
{
	camPos = realCamera;
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	viewPos = (gbufferProjectionInverse * gl_Position).xyz;
// 	playerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	playerPos = mat3(gbufferModelViewInverse) * viewPos;
	worldPos = playerPos + realCamera;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	lmcoord = lmcoord / (30.0 / 32.0) - (1.0 / 32.0);
	glcolor = gl_Color;
	worldNormal = gl_NormalMatrix * gl_Normal;
	worldNormal = mat3(gbufferModelViewInverse) * normalize(worldNormal);
	blockId = int(mc_Entity.x);

	#define wavingWater
	#define wavesHaveToSeeSky
	#ifdef wavingWater
	if (blockId == 1) // && floor(worldPos.y) == 62.0)
	{
		float w = getWaveHeight(worldPos);
		#ifdef wavesHaveToSeeSky
			w *= lmcoord.y * step(0.3, lmcoord.y);
		#endif
		worldPos.y += (w - 0.2) * fract(worldPos.y);
		playerPos = worldPos - camPos;
		viewPos = mat3(gbufferModelView) * playerPos;
		gl_Position = gl_ProjectionMatrix * vec4(viewPos, 1.0);
	}
	#endif
}
