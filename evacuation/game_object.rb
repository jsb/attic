class GameObject
  def initialize
    $game.object_space << self
  end
  
  def update
  end
  
  def draw(scroll_x)
  end
  
  def remove
    $game.object_space.delete(self)
  end
end
