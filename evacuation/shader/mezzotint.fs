uniform sampler2D texUnit0;

uniform int t;

float rand(vec2 co) {
	return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void main(void) {
	vec4 color;

    color = texture2D(texUnit0, gl_TexCoord[0].xy);

	vec3 mezzo = vec3(0.0);
	if(rand(gl_TexCoord[0].xy + float(t)/640.0) <= color.r) { mezzo.r = 1.0; }
	if(rand(gl_TexCoord[0].xy + float(t)/640.0) <= color.g) { mezzo.g = 1.0; }
	if(rand(gl_TexCoord[0].xy + float(t)/640.0) <= color.b) { mezzo.b = 1.0; }
		
    gl_FragColor.rgb = mezzo;
}
