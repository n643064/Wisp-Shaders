#version 330 compatibility

uniform sampler2D gtexture;
uniform mat4 gbufferModelView;

uniform int blockEntityId;

uniform bool isEyeInWater;
uniform float alphaTestRef = 0.1;
uniform sampler2D colortex1;
uniform sampler2D colortex11;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 viewPos;
in vec3 worldPos;
in vec3 playerPos;
in vec3 camPos;
in vec3 worldNormal;
flat in int blockId;
in vec4 gl_FragCoord;

uniform sampler2D depthtex0;


/* RENDERTARGETS: 0,2,3,11 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 outNormal;
layout(location = 2) out vec4 lightmap;
layout(location = 3) out vec4 waterData;

#include "/lib/lighting.glsl"

#define waterAlpha 0.3 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

#define generalWaterFoamStrength 0.1 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0]
#define depthBasedWaterFoamStrength 1.2 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0]
#define waterFoamBorder 0.5 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]


const vec3 waterColor = vec3(0.35, 0.47, 0.7) * 0.8;

#define waterFoam
#ifdef waterFoam
	uniform sampler2D depthtex1;
	uniform float viewWidth, viewHeight;
	uniform float frameTimeCounter;
	uniform sampler2D noisetex0;

	float getOpaqueDepth()
	{
		float d = texelFetch(depthtex1, ivec2(gl_FragCoord.xy), 0).r;
		vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), d);
		vec4 ndcPos = vec4(screenPos, 1.0) * 2.0 - 1.0;
		vec4 tmp = gbufferProjectionInverse * ndcPos;
		vec3 view = tmp.xyz / tmp.w;
		return length(view);
	}
#endif

vec2 warp(vec2 p)
{
	vec2 v = texture(noisetex0, p).xy;
	return p + v;
}

void main()
{
	outNormal = vec4(worldNormal * 0.5 + 0.5, 1.0);
	vec3 normal = worldNormal;
	if (blockId == 1)
	{
		waterData = vec4(1.0, 0.0, 0.0, 1.0);

// 		#define useBiomeWaterColor
		#ifdef useBiomeWaterColor
			color = vec4(glcolor.rgb, waterAlpha);
		#else
			color = vec4(waterColor, waterAlpha);
		#endif

// 		#define waterTexture
		#ifdef waterTexture
			color *= texture(gtexture, texcoord);
		#endif

		#ifdef waterFoam
			float diff = getOpaqueDepth() - length(viewPos);

			#define waterFoamWidth 7.0 // [0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5 8.0 8.5 9.0 9.5 10.0 10.5 11.0 11.5 12.0 12.5 13.0 13.5 14.0 14.5 15.0 15.5 16.0 16.5 17.0 17.5 18.0 18.5 19.0 19.5 20.0]
			#define waterFoamDomainWarpedNoise
			#ifdef waterFoamDomainWarpedNoise
				vec2 p = warp(worldPos.xz / waterFoamWidth - frameTimeCounter / 64.0);
			#else
				vec2 p = worldPos.xz / waterFoamWidth;
			#endif

			#define depthBasedWaterFoam
			#ifdef depthBasedWaterFoam
				vec3 s = texture(noisetex0, p - frameTimeCounter / 16.0).xyz;
				color.rgba += s.x * depthBasedWaterFoamStrength * clamp(waterFoamBorder - diff, 0.0, depthBasedWaterFoamStrength) * step(diff, waterFoamBorder);
			#endif

			#define generalWaterFoam
			#ifdef generalWaterFoam
				vec3 v = texture(noisetex0, p + frameTimeCounter / 32.0).xyz;
				v = pow(v * 1.8, vec3(4.0));
				#define weatherAffectsWaterEffects
				#ifdef weatherAffectsWaterEffects
					color.rgba += v.x * generalWaterFoamStrength * (1.0 + wetness * 0.3);
					color.a += 0.2 * wetness;
				#else
					color.rgba += v.z * generalWaterFoamStrength;
				#endif
			#endif
		#endif

	} else
	{
		color = glcolor * texture(gtexture, texcoord);
		waterData = texelFetch(colortex11, ivec2(gl_FragCoord.xy), 0);
		color.a *= 0.5;
	}

	if (color.a < alphaTestRef)
	{
		discard;
	}

	color.rgb = pow(color.rgb, vec3(2.2));

	WorldData world = getWorldData();

	lightmap = vec4(lmcoord, 0.0, 1.0);
	vec3 lightColor = getLightColor(normal, normalize(camPos - worldPos), lightmap.rg, world);

	color.rgb *= lightColor;
}
