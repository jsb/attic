class Bunker < GameObject
  attr_accessor :grid_x, :grid_y
  
  def initialize(grid_x, grid_y)
    super()
    
    @grid_x = grid_x
    @grid_y = grid_y
    @r = -1+rand*2
  end
  
  def x; @grid_x*Game::TileSize + Game::TileSize/2; end
  def y; @grid_y*Game::TileSize + Game::TileSize/2; end
  
  def update
    remove if x - $game.wall_x < -Game::TileSize/2
  end
  
  def draw(scroll_x)
    $image['game/bunker.png'].draw_rot(x - scroll_x, y, ZOrder::Bunkers, @r)
  end
end
