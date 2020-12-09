class RoadTile < GameObject
  attr_reader :grid_x, :grid_y
  
  def initialize(grid_x, grid_y, from, to)
    super()
    
    @grid_x = grid_x
    @grid_y = grid_y
    @from = from
    @to = to
  end
  
  def x
    @grid_x*Game::TileSize
  end
  
  def update
    remove if x - $game.wall_x < -Game::TileSize/2
  end
  
  def draw(scroll_x)
    screen_x = x - scroll_x
    screen_y = @grid_y*Game::TileSize
    
    $tile['game/road_we.png'].draw(screen_x,screen_y, ZOrder::Roads) if @from == :west and @to == :east
    $tile['game/road_ns.png'].draw(screen_x,screen_y, ZOrder::Roads) if @from == :north and @to == :south
    $tile['game/road_ns.png'].draw(screen_x,screen_y, ZOrder::Roads) if @from == :south and @to == :north
    
    $tile['game/road_ws.png'].draw(screen_x,screen_y, ZOrder::Roads) if @from == :west and @to == :south
    $tile['game/road_wn.png'].draw(screen_x,screen_y, ZOrder::Roads) if @from == :west and @to == :north
    $tile['game/road_ne.png'].draw(screen_x,screen_y, ZOrder::Roads) if @from == :north and @to == :east
    $tile['game/road_se.png'].draw(screen_x,screen_y, ZOrder::Roads) if @from == :south and @to == :east
  end
  
  def advance
    new_from = :west if @to == :east
    new_from = :south if @to == :north
    new_from = :north if @to == :south
    dirs = [:east, :south, :north, @to, @to]-[new_from]
    dirs -= [:north] if @grid_y <= 5
    dirs -= [:south] if @grid_y >= 9
    new_to = dirs.pick
    new_x, new_y = @grid_x+1, @grid_y if @to == :east
    new_x, new_y = @grid_x, @grid_y-1 if @to == :north
    new_x, new_y = @grid_x, @grid_y+1 if @to == :south
    
    $game.object_space.find_all {|o| o.is_a?(RoadTile) or o.is_a?(House) or o.is_a?(Bunker) and o.grid_x == new_x and o.grid_y == new_y }.each do |obj|
      obj.remove
    end
    r = RoadTile.new(new_x, new_y, new_from, new_to)
    
    house_x = r.grid_x - 1 + rand(3)
    house_y = r.grid_y - 1 + rand(3)
    unless $game.object_space.find {|o| o.is_a?(RoadTile) or o.is_a?(House) or o.is_a?(Bunker) and o.grid_x == house_x and o.grid_y == house_y }
      House.new(house_x, house_y)
    end
    
    $game.road_end = r
  end
end
