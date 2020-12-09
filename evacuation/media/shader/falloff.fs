uniform sampler2D tex;

void main(void) {
	vec3 color = texture2D(tex, vec2(gl_TexCoord[0])).rgb;
	vec3 desaturated = vec3(color.r + color.g + color.b)/3.0;
	
	float blend = max(min((desaturated.r-0.5)*2.0 + 0.5, 1.0), 0.0);
	gl_FragColor.rgb = mix(desaturated, color, blend);
}
