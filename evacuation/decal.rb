class Decal < GameObject
  def initialize(image, x, y, size=1.0)
    super()
    
    @x = x
    @y = y
    @r = rand*360
    @image = image
    @size = size
  end
  
  def update
    remove if @x - $game.wall_x < -32
  end
  
  def draw(scroll_x)
    @image.draw_rot(@x-scroll_x, @y, ZOrder::Decals, @r, 0.5,0.5, @size,@size)
  end
end
