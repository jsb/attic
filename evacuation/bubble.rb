class Bubble < GameObject
  def initialize(parent, image)
    super()
    @parent = parent
    @frame = 0
    @image = image
  end
  
  def update
    @frame += 1
    remove if @frame >= 128
    remove unless @parent
  end
  
  def draw(scroll_x)
    size = (@frame*0.1).bound_by(0.0, 1.0)
    alpha = (1024-@frame*8).bound_by(0, 255)
    @image.draw_rot(@parent.x - scroll_x, @parent.y, ZOrder::Overlay, 0, 0.5,1.5, size,size, Gosu::Color.new(alpha, 255,255,255))
  end
end
