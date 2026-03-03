#ifndef BLUR_GLSL
#define BLUR_GLSL
	vec3 blur(sampler2D image, vec2 center, vec2 resolution)
	{
		vec2 d1 = vec2(1.3333) / resolution;
		vec2 d2 = vec2(2.6666) / resolution;
		vec2 d3 = vec2(5.1111) / resolution;

		vec3 c = texture(image, center).rgb * 0.2;

		c += texture(image, center + d1).rgb * 0.2;
		c += texture(image, center - d1).rgb * 0.2;
		c += texture(image, center + d2).rgb * 0.15;
		c += texture(image, center - d2).rgb * 0.15;
		c += texture(image, center + d3).rgb * 0.05;
		c += texture(image, center - d3).rgb * 0.05;

		return c;
	}
#endif
