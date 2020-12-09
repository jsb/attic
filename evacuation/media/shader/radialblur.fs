uniform sampler2D Texture;

uniform float BlurFactor;
uniform float BrightFactor;

uniform float origin_x;
uniform float origin_y;

uniform int passes;

void main(void)
{
	vec2 Origin = vec2(origin_x, 1.0 - origin_y);

	vec2 TexCoord = vec2(gl_TexCoord[0].xy);

	vec4 SumColor = vec4(0.0, 0.0, 0.0, 0.0);
	TexCoord += vec2(1.0 / 1024.0, 1.0 / 768.0) * 0.5 - Origin;

	for (int i = 0; i < passes; i++) 
	{
		float scale = 1.0 - BlurFactor * (float(i) / float(passes - 1));
		SumColor += texture2D(Texture, TexCoord * scale + Origin);
	}

	gl_FragColor = SumColor / float(passes) * BrightFactor;
	//gl_FragColor = texture2D(Texture, gl_TexCoord[0].xy + vec2(0.1));
}
