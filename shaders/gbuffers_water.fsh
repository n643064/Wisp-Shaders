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

#define waterAlpha 0.6 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

#define generalWaterFoamStrength 0.1 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0]
#define depthBasedWaterFoamStrength 1.2 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0]
#define waterFoamBorder 0.5 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

const vec3 waterColor = vec3(0.35, 0.47, 0.7) * 0.8;
uniform float frameTimeCounter;

uniform sampler2D noisetex0;

// #define waterFoam
#ifdef waterFoam
	uniform sampler2D depthtex1;
	uniform float viewWidth, viewHeight;

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


#define reflectSky
#ifdef reflectSky
	#include "/lib/sky.glsl"
	#include "/lib/clouds.glsl"
#endif


void main()
{
	outNormal = vec4(worldNormal * 0.5 + 0.5, 1.0);
	vec3 normal = worldNormal;
	lightmap = vec4(lmcoord, 0.0, 1.0);
	WorldData world = getWorldData();

	if (blockId == 1)
	{
		waterData = vec4(1.0, 0.0, 0.0, 1.0);

// 		#define useBiomeWaterColor
		#ifdef useBiomeWaterColor
			color = vec4(glcolor.rgb, waterAlpha);
		#else
			color = vec4(waterColor, waterAlpha);
		#endif

		#define waterSaturatedBasedOnSkylight
		#ifdef waterSaturatedBasedOnSkylight
			color.rgba *= vec4(lightmap.g, lightmap.g, lightmap.g, 2.0-lightmap.g);
			color.a = clamp(color.a, 0.0, 0.9);
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
		#define waterNormals
		#ifdef waterNormals
			#define waterNormalSpeed 0.06 // [0.0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.3 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.4 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.5 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.6 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.7 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.0]
			#define waterNormalWidth 7.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0 4.1 4.2 4.3 4.4 4.5 4.6 4.7 4.8 4.9 5.0 5.1 5.2 5.3 5.4 5.5 5.6 5.7 5.8 5.9 6.0 6.1 6.2 6.3 6.4 6.5 6.6 6.7 6.8 6.9 7.0 7.1 7.2 7.3 7.4 7.5 7.6 7.7 7.8 7.9 8.0 8.1 8.2 8.3 8.4 8.5 8.6 8.7 8.8 8.9 9.0 9.1 9.2 9.3 9.4 9.5 9.6 9.7 9.8 9.9 10.0]
			vec2 pos = warp(worldPos.xz / waterNormalWidth) + frameTimeCounter * waterNormalSpeed;
			vec3 ns = texture(noisetex0, pos).xyz;
			vec3 ns2 = texture(noisetex0, -pos).xyz;
			normal = normalize(normal + ns - ns2);
		#endif
		#ifdef reflectSky
			if (!isEyeInWater && lightmap.g > 0.3)
			{

				vec3 playerReflected = reflect(normalize(playerPos), normal);
				vec3 c = getSkyColor(normalize(playerReflected), world);
				float cd = (bedrockLevel + heightLimit) - camPos.y - cloudHeightOffset * 5.0;
// 				#define useFresnel
				#ifdef useFresnel
					float fresnel = max(pow(1.25 - dot(playerReflected, normal), 5.0), 0);
					fresnel = clamp(fresnel, 0.2, 0.8) * lightmap.g;
				#else
					#define fresnel (1.0 * lightmap.g)
				#endif
				color.rgb = mix(color.rgb, c, fresnel * 0.4);
				#define customClouds
				#ifdef customClouds
					applyClouds(color.rgb, playerReflected, cd, world, fresnel);
				#endif
			}
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



	vec3 lightColor = getLightColor(normal, normalize(camPos - worldPos), lightmap.rg, world);
	outNormal = vec4(normal, 1.0);
	color.rgb *= lightColor;
}
