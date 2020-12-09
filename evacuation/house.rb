class House < GameObject
  attr_reader :grid_x, :grid_y
  def initialize(grid_x, grid_y)
    super()
    
    @pic = $image["game/house#{1+rand(8)}.png"]
    @grid_x = grid_x
    @grid_y = grid_y
    @r = -5+rand*10
    
    @inhabitants = 0
    @inhabitants = rand($game.max_inhabitants) if $game.frame > 30
  end
  
  def x; @grid_x*Game::TileSize + Game::TileSize/2; end
  def y; @grid_y*Game::TileSize + Game::TileSize/2; end
  
  def update
    remove if x - $game.wall_x < -Game::TileSize/2
    
    if @inhabitants > 0 and ((rand(40).zero? and x - $game.wall_x < 480)  or rand(2500).zero?)
      Villager.new(x,y)
      @inhabitants -= 1
    end
  end
  
  def draw(scroll_x)
    @pic.draw_rot(x - scroll_x, y, ZOrder::Scenery, @r)
    @pic.draw_rot(x - scroll_x + 3, y + 3, ZOrder::Shadows, @r, 0.5,0.5, 1,1, 0x88000000)
    
    if @inhabitants > 0
      $font['Verdana', 12].draw_rel("#{@inhabitants}", x-scroll_x,y, ZOrder::Overlay, 1,0.5, 1,1, 0x88ffffff)
      $image['game/person_picto.png'].draw_rot(x-scroll_x+4,y, ZOrder::Overlay, 0, 0.5,0.5, 0.8,0.8, 0x88ffffff)
    end
  end
  
  def collapse
    $sound["game/house_crash#{1+rand(3)}.wav"].play(rand*0.2, 0.8+rand*0.4)
    Decal.new($image["game/ruin#{1+rand(2)}.png"], x, y, 1.4)
    Particle.new($image['game/shockwave.png'], x, y, 0,0, rand*360,-1+rand*2, 0.5,+0.025, 255,-4)
    remove
  end
  
  def empty
    while @inhabitants > 0
      Villager.new(x,y)
      @inhabitants -= 1
    end
  end
end
