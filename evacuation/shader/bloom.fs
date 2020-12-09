uniform sampler2D tex;

uniform int direction;
uniform int passes;
uniform int screen_width;
uniform int screen_height;
uniform float scale;

void main(void)
{
  vec2 coord = gl_TexCoord[0].xy;
  vec2 axis = direction == 0 ? vec2(scale/float(screen_width), 0.0) : vec2(0.0, scale/float(screen_height));
  vec3 color = texture2D(tex, coord).rgb;
  
  vec3 sum = vec3(0.0);
  
  for(int i = 0; i < passes; i++)
  {
    vec2 offset = vec2(float(i) + 0.5 - float(passes)*0.5)*axis;
    sum += texture2D(tex, coord + offset).rgb;
  }
  
  gl_FragColor.rgb = sum/float(passes);
  gl_FragColor.a = 1.0;
}
