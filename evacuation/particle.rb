class Particle < GameObject
  def self.cast(image, amt, x,y, dx,dy,dvar, afade)
    amt.times do
      Particle.new(image, x,y, dx-dvar/2+rand*dvar,dy-dvar/2+rand*dvar, rand*360,0, 1,0, 255,-afade)
    end
  end
  
  def initialize(image, x,y, dx=00,dy=00, r=0,dr=0, size=1,dsize=0, alpha=255,dalpha=0, mode=:default)
    super()
    
    @image = image
    @x, @y = x, y
    @dx, @dy = dx, dy
    @r, @dr = r, dr
    @size, @dsize = size, dsize
    @alpha, @dalpha = alpha, dalpha
    @mode = mode
  end
  
  def update
    @x += @dx
    @y += @dy
    @r += @dr
    @size += @dsize
    @alpha = (@alpha+@dalpha).bound_by(0,255)
    
    remove if @size <= 0
    remove if @alpha <= 0
  end
  
  def draw(scroll_x)
    @image.draw_rot(@x-scroll_x, @y, ZOrder::Particles, @r, 0.5,0.5, @size,@size, Gosu::Color.new(@alpha.floor, 255,255,255), @mode)
  end
end
