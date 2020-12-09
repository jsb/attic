class ShakeEffect
  attr_accessor :intensity
  
  Epsilon = 0.02
  
  def initialize(window)
    @intensity = 0.0
    
    @shader = Shader.new(window, 'media/shader/radialblur.fs')
    @shader['origin_x'] = 0.5
    @shader['origin_y'] = 0.5
    @shader['passes'] = 5
    @shader['BlurFactor'] = 0.01
    @shader['BrightFactor'] = 1.0
  end
  
  def update
    @intensity *= 0.95
    
    @shader['origin_x'] = 0.05 + 0.05*Math.sin(Gosu::milliseconds * 0.0309)
    @shader['origin_y'] = 0.5 + 0.5*Math.sin(Gosu::milliseconds * 0.0401)
    
    @shader['BlurFactor'] = 0.02*@intensity
  end
  
  def apply
    @shader.apply if @intensity > Epsilon
  end
end
