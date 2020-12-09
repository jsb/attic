class GameOverEffect
  attr_accessor :on
  
  def initialize(window)
    @falloff = Shader.new(window, 'media/shader/falloff.fs')
    @on = false
  end
  
  def update
    
  end
  
  def apply
    @falloff.apply if @on
  end
end
