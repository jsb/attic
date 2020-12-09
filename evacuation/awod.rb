class AWoD < GameObject
  attr_accessor :frozen
  
  def initialize
    super()
    @frame = 0
    @zoom = 1.0
    @shadow_alpha = 0
    
    @frozen = 0
  end
  
  def update
    return @frozen -= 1 if @frozen > 0
    
    func = Math.sin(@frame*0.012).abs
    @frame += 1
    @zoom = 1.0 + 0.25*func
    @shadow_alpha = 255-(128*func).round
    
    if @frame*0.012 >= Math::PI
      # boom! crush it
      $sound['game/awod_falling.wav'].play(0.4, 0.85+rand*0.3)
      
      # shader effect
      $game.shake_effect.intensity = 1.0
      
      incidents = 0
      $game.object_space.find_all {|o| o.is_a?(Villager) and o.x <= $game.wall_x + 54 }.each do |o|
        o.die
        incidents += 1
      end
      
      if incidents > 0 and not $game.game_over or $game.won
        $sound['game/fatality.wav'].play(0.9)
        $game.damage_effect.intensity = 1.0
      end
      
      $game.object_space.find_all {|o| o.is_a?(House) and o.x <= $game.wall_x + 64 }.each do |o|
        o.collapse
      end
      
      if $game.player.alive and $game.player.x <= $game.wall_x + 54
        $game.player.die
      end
      
      # loop
      @frame -= 1 while @frame*0.012 >= 0
    end
  end
  
  def draw(scroll_x)
    $image['game/awod.png'].draw_rot(146,240, ZOrder::Wall, 0, 2.5,0.5, @zoom,@zoom)
    $image['game/awod_shadow.png'].draw_rot(32,240, ZOrder::WallShadow, 0, 0.5,0.5, 1.0,1.0, Gosu::Color.new(@shadow_alpha, 0,0,0))
    
    # big shadow
    $image['game/shadow.png'].draw_rot(0.8,240+240*Math.sin($game.frame*0.005), ZOrder::WallShadow, 0, 0.0,0.5, 2.0,2.5 + 0.5*Math.sin(@frame*0.011), 0x88000000)
  end
end
