class Game < Scene
  TileSize = 32
  PowerupInterval = 50
  
  attr_accessor :object_space, :road_end, :wall_x, :frame, :player, :awod, :game_over, :won, :rescued, :lost, :paused, :shake_effect, :damage_effect, :game_over_effect
  
  def initialize(window)
    super(window)
    $game = self
    
    @wall_pos = 0
    @wall_x = 0.0
    @wall_speed = 0.3
    @frame = 0
    
    @object_space = []
    @powerups = []
    @powerups << Powerup.random
    @powerups << Powerup.random
    @powerups << Powerup.random
    @powerups << Powerup.random
    @next_powerup = 50
    
    @road_end = RoadTile.new(0,3+rand(9), :west, :east)
    @awod = AWoD.new
    @player = PlayerCharacter.new(320, 240)
    
    @rescued = 0
    @lost = 0
    @game_over = false
    @won = false
    @paused = false
    
    @rescued_goal = 300
    @lost_tolerance = 10
    Message.new("Rescue #{@rescued_goal} villagers without losing #{@lost_tolerance}!")
    
    @fpscounter = FPSCounter.new
    
    @shake_effect = ShakeEffect.new(window)
    @damage_effect = DamageEffect.new(window)
    @game_over_effect = GameOverEffect.new(window)
  end
  
  def update
    return if @paused
    
    if @lost >= @lost_tolerance and not @game_over
      @damage_effect.intensity = 0.5
      @damage_effect.decay = 0.995
      
      @game_over_effect.on = true
      
      $sound["game/game_over.wav"].play(1.0)
      @game_over = true
    end
    win if @rescued >= @rescued_goal
    
    while @rescued >= @next_powerup
      p = Powerup.random
      Message.new("Got Powerup: #{p.name}")
      @powerups << p
      @next_powerup += PowerupInterval
    end
    
    # @wall_x += @wall_speed if active and @awod.frozen <= 0
    @wall_pos += 1 if active and @awod.frozen <= 0
    @wall_x = @wall_pos * @wall_speed
    @frame += 1
    
    # advance roads
    @road_end.advance until @road_end.x > @wall_x + 640 + Game::TileSize*2
    # place bunkers
    if (@road_end.grid_x % 6).zero? and not $game.object_space.find {|o| o.is_a?(Bunker) and o.grid_x == @road_end.grid_x }
      bunker_y = 1+rand(13) while bunker_y.nil? or $game.object_space.find {|o| (o.is_a?(House) or o.is_a?(RoadTile)) and o.grid_y == bunker_y }
      Bunker.new(@road_end.grid_x, bunker_y)
    end
    
    @object_space.each do |o|
      o.update
    end
    
    @fpscounter.register_tick
    @window.caption = "Evacuation: #{@fpscounter.fps} fps, #{@object_space.size} objects" if (@frame%60).zero?
    
    @shake_effect.update
    @damage_effect.update
  end
  
  def draw
    # landscape background
    $tile['game/landscape.png'].draw((-@wall_x)%640-640,0, ZOrder::Landscape)
    $tile['game/landscape.png'].draw((-@wall_x)%640,0, ZOrder::Landscape)
    
    @object_space.each do |o|
      o.draw(@wall_x)
    end
    
    @shake_effect.apply
    @damage_effect.apply
    @game_over_effect.apply
    
    # the HUD
    if @paused
      $game.window.draw_quad(0,0, 0x44000088, 640,0, 0x44000088, 0,480, 0x44000088, 640,480, 0x44000088, ZOrder::HUD)
      
      $font['Verdana', 32].draw_rel("Pause", 321, 241, ZOrder::HUD, 0.5,0.5, 1,1, 0xff000000)
      $font['Verdana', 32].draw_rel("Pause", 320, 240, ZOrder::HUD, 0.5,0.5)
    else
      if @won
        $font['Verdana', 32].draw_rel("You Win!", 321, 241, ZOrder::HUD, 0.5,0.5, 1,1, 0xff000000)
        $font['Verdana', 32].draw_rel("You Win!", 320, 240, ZOrder::HUD, 0.5,0.5)
        
        $font['Verdana', 20].draw_rel("RETURN - Retry", 321, 281, ZOrder::HUD, 0.5,0.5, 1,1, 0xff000000)
        $font['Verdana', 20].draw_rel("RETURN - Retry", 320, 280, ZOrder::HUD, 0.5,0.5)
        $font['Verdana', 20].draw_rel("ESC - Main Menu", 321, 301, ZOrder::HUD, 0.5,0.5, 1,1, 0xff000000)
        $font['Verdana', 20].draw_rel("ESC - Main Menu", 320, 300, ZOrder::HUD, 0.5,0.5)
      elsif @game_over
        $game.window.draw_quad(0,0, 0x22ff0000, 640,0, 0x22ff0000, 0,480, 0x22ff0000, 640,480, 0x22ff0000, ZOrder::HUD)
        
        $font['Verdana', 32].draw_rel("Game Over", 321, 241, ZOrder::HUD, 0.5,0.5, 1,1, 0xff000000)
        $font['Verdana', 32].draw_rel("Game Over", 320, 240, ZOrder::HUD, 0.5,0.5)
        
        $font['Verdana', 20].draw_rel("RETURN - Retry", 321, 281, ZOrder::HUD, 0.5,0.5, 1,1, 0xff000000)
        $font['Verdana', 20].draw_rel("RETURN - Retry", 320, 280, ZOrder::HUD, 0.5,0.5)
        $font['Verdana', 20].draw_rel("ESC - Main Menu", 321, 301, ZOrder::HUD, 0.5,0.5, 1,1, 0xff000000)
        $font['Verdana', 20].draw_rel("ESC - Main Menu", 320, 300, ZOrder::HUD, 0.5,0.5)
      end
      
      # status text
      $font['Verdana', 20].draw_rel("#{@rescued}/#{@rescued_goal} rescued", 639, 3, ZOrder::HUD, 1.0,0.0, 1,1, 0xff000000)
      $font['Verdana', 20].draw_rel("#{@rescued}/#{@rescued_goal} rescued", 638, 2, ZOrder::HUD, 1.0,0.0)
      
      $font['Verdana', 20].draw_rel("#{@lost}/#{@lost_tolerance} lost", 639, 23, ZOrder::HUD, 1.0,0.0, 1,1, 0xff000000)
      $font['Verdana', 20].draw_rel("#{@lost}/#{@lost_tolerance} lost", 638, 22, ZOrder::HUD, 1.0,0.0)
      
      # powerups
      @powerups.each_with_index do |p, i|
        x = 640 - 32*(@powerups.size - i)
        y = 480 - 32
        if i == 0
          $image['game/powerup_glow.png'].draw(x,y, ZOrder::HUD)
          $font['Verdana', 20].draw_rel("#{p.name}", x-3, y+17, ZOrder::HUD, 1.0,0.5, 1,1, 0xff000000)
          $font['Verdana', 20].draw_rel("#{p.name}", x-4, y+16, ZOrder::HUD, 1.0,0.5)
        end
        p.image.draw(x,y, ZOrder::HUD)
      end
    end
  end
  
  def button_down(id)
    case id
      when Gosu::KbEscape
        @window.scene = MainMenu.new(@window)
      when Gosu::KbP, Gosu::GpButton9
        @paused = !@paused
      when Gosu::KbReturn
        @window.scene = Game.new(@window) if @game_over or @won
      when Gosu::KbE, Gosu::GpButton1
        if active and @powerups[0]
          @powerups.shift.activate
        end
      when Gosu::KbTab, Gosu::GpButton2
        if active and @powerups.size >= 2
          @powerups << @powerups.shift
        end
    end
      
    super
  end
  
  def max_inhabitants
    # kind of a difficulty formula
    (3 + @rescued/100).floor
  end
  
  def active
    !(@paused || @game_over || @won)
  end
  
  def win
    return if @won
    @won = true
    $sound["game/win.wav"].play(1.0)
    @awod.remove
    $game.object_space.find_all {|o| o.is_a?(Villager)}.each do |o|
      o.state = :cheering
    end
  end
end
