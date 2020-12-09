class Message < GameObject
  def initialize(text)
    super()
    @text = text
    @age = 30 + text.length*3
    @alpha = 255
  end
  
  def update
    if @age > 0
      @age -= 1
    else
      @alpha -= 8
      remove if @alpha <= 0
    end
  end
  
  def draw(scroll_x)
    $font['Verdana', 30].draw_rel(@text, 321, 241, ZOrder::HUD, 0.5,0.5, 1,1, Gosu::Color.new(@alpha, 0,0,0))
    $font['Verdana', 30].draw_rel(@text, 320, 240, ZOrder::HUD, 0.5,0.5, 1,1, Gosu::Color.new(@alpha, 255,255,255))
  end
end
