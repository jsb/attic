class DamageEffect
  attr_accessor :intensity, :decay
  
  Epsilon = 0.01
  
  def initialize(window)
    @intensity = 0.0
    @decay = 0.95
    
    @noise = Shader.new(window, 'media/shader/noise.fs')
    @noise['intensity'] = 0.0
    @noise['t'] = 0
    
    @contrast = Shader.new(window, 'media/shader/contrast.fs')
    @contrast['contrast'] = 1.0
  end
  
  def update
    @intensity *= @decay
    
    @noise['intensity'] = @intensity
    @noise['t'] = Gosu::milliseconds % 640
    
    @contrast['contrast'] = 1.0 + @intensity
  end
  
  def apply
    if @intensity > Epsilon
      @noise.apply
      @contrast.apply
    end
  end
end
