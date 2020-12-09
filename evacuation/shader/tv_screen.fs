uniform sampler2D texUnit0;

uniform float column_width;

void main(void)
{
    vec3 color = texture2D(texUnit0, gl_TexCoord[0].xy).rgb;
	
	float column_index = gl_TexCoord[0].x / column_width;
	int ci = int(column_index);
	while(ci >= 3) { ci -= 3; } // % doesn't seem to work
	
	gl_FragColor.rgb = color * 0.125;
	if(ci==0) { gl_FragColor.r = color.r; }
 	if(ci==1) { gl_FragColor.g = color.g; }
	if(ci==2) { gl_FragColor.b = color.b; }
}
