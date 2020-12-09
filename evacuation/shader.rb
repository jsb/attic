begin
  require 'rubygems'
rescue
end
require 'gl'

class Shader
  include Gl
  
  attr_reader :window, :shader_filename
  attr_reader :program_id, :vertex_shader_id, :fragment_shader_id
  
  @@canvas_texture_id = nil
  
  def initialize(window, shader_filename)
    @window = window
    @shader_filename = shader_filename
    
    @program_id = nil
    @vertex_shader_id = nil
    @fragment_shader_id = nil
    
    create_canvas unless @@canvas_texture_id
    compile
  end
  
  def apply
    @window.gl do
      # copy frame buffer to canvas texture
      glBindTexture(GL_TEXTURE_2D, @@canvas_texture_id)
      glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, 0, 0, @window.width, @window.height, 0)
      
      # apply shader
      glUseProgram(@program_id)
      
      # clear screen
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
      glColor4f(1.0, 1.0, 1.0, 1.0)
      glMatrixMode(GL_PROJECTION)
      glPushMatrix
      glLoadIdentity
      glViewport(0, 0, @window.width, @window.height)
      glOrtho(0, @window.width, @window.height, 0, -1, 1)
      
      # draw processed canvas texture over the screen
      glBindTexture(GL_TEXTURE_2D, @@canvas_texture_id)
      
      glBegin(GL_QUADS)
        glTexCoord2f(0.0, 1.0); glVertex2f(0.0,           0.0)
        glTexCoord2f(1.0, 1.0); glVertex2f(@window.width, 0.0)
        glTexCoord2f(1.0, 0.0); glVertex2f(@window.width, @window.height)
        glTexCoord2f(0.0, 0.0); glVertex2f(0.0,           @window.height)
      glEnd
      
      # done, disable shader
      glUseProgram(0)
      
      # and out
      glPopMatrix
    end
  end
  
  def uniform(name, value)
    glUseProgram(@program_id)
    if value.is_a?(Float)
      glUniform1f(glGetUniformLocation(@program_id, name), value)
    elsif value.is_a?(Integer)
      glUniform1i(glGetUniformLocation(@program_id, name), value)
    else
      raise ArgumentError, "Uniform data type not supported"
    end
    glUseProgram(0)
  end
  
  alias []= uniform
  
  private
  
  def create_canvas
    @@canvas_texture_id = glGenTextures(1).first
    glBindTexture(GL_TEXTURE_2D, @@canvas_texture_id)
    glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, 1)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, @window.width, @window.height, 0, GL_RGB, GL_UNSIGNED_BYTE, "\0" * @window.width * @window.height * 3)
    return @@canvas_texture_id
  end
  
  def compile
    # create program
    @program_id = glCreateProgram
    
    # create vertex shader
    @vertex_shader_id = glCreateShader(GL_VERTEX_SHADER)
    glShaderSource(@vertex_shader_id, "void main(void)\r\n{\r\ngl_Position = ftransform();\r\ngl_TexCoord[0] = gl_MultiTexCoord0;\r\n}\r\n")
    glCompileShader(@vertex_shader_id)
    glAttachShader(@program_id, @vertex_shader_id)
    
    # create fragment shader
    @fragment_shader_id = glCreateShader(GL_FRAGMENT_SHADER)
    glShaderSource(@fragment_shader_id, File.read(@shader_filename))
    glCompileShader(@fragment_shader_id)
    glAttachShader(@program_id, @fragment_shader_id)
    
    # compile program
    glLinkProgram(@program_id)
    
    # check for compile errors
    unless glGetProgramiv(@program_id, GL_LINK_STATUS) == GL_TRUE
      raise glGetProgramInfoLog(@program_id).chomp
    end
    
    return @program_id
  end
end
