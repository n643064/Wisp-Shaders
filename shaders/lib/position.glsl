#ifndef POSITION_GLSL
#define POSITION_GLSL

	#include "/lib/common.glsl"


	struct PositionData
	{
		float depth;
		vec3 camera;
		vec3 screen;
		vec3 view;
		vec3 player;
		vec3 playerFeet;
		vec3 world;
		float dist;
		vec3 viewNormalized;
	};

	PositionData getPositionData(sampler2D depthtex, vec3 camera)
	{
		PositionData pos;
		pos.depth = texture(depthtex, texcoord).r;
		pos.screen = vec3(texcoord, pos.depth);
		vec3 ndc = pos.screen * 2.0 - 1.0;

		vec4 tmp = gbufferProjectionInverse * vec4(ndc, 1.0);
		pos.view = tmp.xyz / tmp.w;
		pos.playerFeet = mat3(gbufferModelViewInverse) * pos.view;
		pos.player = (gbufferModelViewInverse * vec4(pos.view, 1.0)).xyz;

		pos.world = pos.player + camera;
		pos.dist = length(pos.view);
		pos.viewNormalized = pos.view / pos.dist;
		return pos;
	}

#endif
