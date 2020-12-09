uniform sampler2D texUnit0;

uniform float fade;

void main(void) {
	vec4 color;

    color = texture2D(texUnit0, gl_TexCoord[0].xy);
	
    gl_FragColor = color * fade;
}
