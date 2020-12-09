uniform sampler2D texUnit0;

uniform float intensity;
uniform int t;

float rand(vec2 co) {
	return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void main(void) {
	vec4 color;

    color = texture2D(texUnit0, gl_TexCoord[0].xy);
	
	vec4 influence = min(color, 1.0-color);
	
	float noise = 1.0 - 2.0*rand(gl_TexCoord[0].xy + float(t)/640.0);
	
    gl_FragColor = color + intensity*influence*noise;
}
