class PlayerCharacter < GameObject
  attr_accessor :x, :y, :alive, :indicator_size, :speed
  
  def initialize(x, y)
    super()
    
    @x = x
    @y = y
    @color = 0xffffffff
    @r = rand*360
    @speed = 1.0
    @alive = true
    
    @indicator_size = 5.0
  end
  
  def update
    # movement
    xd = 0
    yd = 0
    
    xd -= @speed if $game.window.button_down?(Gosu::KbA) or $game.window.button_down?(Gosu::GpLeft)
    xd += @speed if $game.window.button_down?(Gosu::KbD) or $game.window.button_down?(Gosu::GpRight)
    yd -= @speed if $game.window.button_down?(Gosu::KbW) or $game.window.button_down?(Gosu::GpUp)
    yd += @speed if $game.window.button_down?(Gosu::KbS) or $game.window.button_down?(Gosu::GpDown)
    
    $game.object_space.find_all {|o| o.is_a?(House) and Gosu::distance(@x, @y, o.x, o.y) <= 17 }.each do |o|
      angle = Gosu::angle(o.x, o.y, @x, @y)
      xd += Gosu::offset_x(angle, @speed)
      yd += Gosu::offset_y(angle, @speed)
    end
    
    @x = (@x+xd).bound_by(0+$game.wall_x,640+$game.wall_x)
    @y = (@y+yd).bound_by(0,480)
    
    @r = Gosu::angle(0,0, xd,yd) unless xd.zero? and yd.zero?
    
    # indicator
    @indicator_size -= 0.04 if @indicator_size > 0
    if $game.window.button_down?(Gosu::KbSpace)
      @indicator_size = 1.8 unless $game.paused or $game.game_over or @indicator_size > 1.8
    end
  end
  
  def draw(scroll_x)
    $image['game/body_walking.png'].draw_rot(@x-scroll_x, @y, ZOrder::People, @r, 0.5,0.5, 1.0,1.0, @color)
    $image['game/body_walking.png'].draw_rot(@x-scroll_x + 2, @y + 2, ZOrder::People, @r, 0.5,0.5, 1.0,1.0, 0x88000000)
    $image['game/head.png'].draw_rot(@x-scroll_x, @y, ZOrder::People, @r)
    
    # indicator
    $image['game/glow.png'].draw_rot(@x-scroll_x, @y, ZOrder::Glow, 0, 0.5,0.5, 2.0,2.0, 0x44ffffff)
    $image['game/player_indicator.png'].draw_rot(@x-scroll_x, @y, ZOrder::Overlay, ($game.frame*1.9)%360, 0.5,0.5, @indicator_size,@indicator_size, 0x88ffffff) if @indicator_size > 0
  end
  
  def die
    @alive = false
    Decal.new($image["game/blood_splat#{1+rand(2)}.png"], @x, @y, 2.5)
    Particle.cast($image['game/blood_drop.png'], 30, x,y, 0.5,-0.5+rand,1, 5)
    remove
    $sound["game/game_over.wav"].play(1.0)
    
    $game.damage_effect.intensity = 0.5
    $game.damage_effect.decay = 0.995
    
    $game.shake_effect.intensity = 3.0
    
    $game.game_over_effect.on = true
    
    $game.game_over = true
  end
end
