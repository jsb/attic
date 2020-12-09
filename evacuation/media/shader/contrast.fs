uniform sampler2D tex;
uniform float contrast;

void main(void)
{
  vec4 color = texture2D(tex, gl_TexCoord[0].xy);
  
  color = (color-0.5)*contrast + 0.5;
  
  gl_FragColor.rgb = color.rgb;
  gl_FragColor.a = 1.0;
}
