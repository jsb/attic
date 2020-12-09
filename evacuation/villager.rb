class Villager < GameObject
  FollowPlayerDistance = 32
  FollowPlayerPanicDistance = 64 # distance to follow player when nearing the wall and calling for help
  EvacuateDistance = 64 # distance to search for bunkers
  PanicDistance = 128 # when to call for help when nearing the wall
  
  attr_accessor :x, :y, :state, :speed
  
  def initialize(x, y)
    super()
    
    @x = x
    @y = y
    
    @r = rand*360
    @color = Gosu::Color.new(255, rand(255),rand(255),rand(255))
    @state = :wandering
    @speed = 0.5
    @target = nil
    @last_alert = 0
  end
  
  def update
    if @state == :wandering
      @r += -10+rand*20
      
      # don't wander out of the screen
      if @y < 64
        @r = Gosu::angle(0,0, Gosu::offset_x(@r, @speed), Gosu::offset_y(@r, @speed)+@speed*0.05)
      end
      if @y > 480-64
        @r = Gosu::angle(0,0, Gosu::offset_x(@r, @speed), Gosu::offset_y(@r, @speed)-@speed*0.05)
      end
      if @x > $game.wall_x + 640
        @r = Gosu::angle(0,0, Gosu::offset_x(@r, @speed)-@speed*0.05, Gosu::offset_y(@r, @speed))
      end
      
      @x += Gosu::offset_x(@r, @speed)
      @y += Gosu::offset_y(@r, @speed)
      
      # follow player
      if $game.player.alive
        if @x - $game.wall_x < PanicDistance and Gosu::distance(@x, @y, $game.player.x, $game.player.y) < FollowPlayerPanicDistance \
        or Gosu::distance(@x, @y, $game.player.x, $game.player.y) < FollowPlayerDistance
          @state = :following
          Bubble.new(self, $image['game/bubble_following.png'])
          $sound["game/follow.wav"].play(0.2, 0.9+rand*0.2)
        end
      end
      
      # alert if nearing The Wall
      if @last_alert >= 128 and @x - $game.wall_x < PanicDistance
        @last_alert = 0
        Bubble.new(self, $image['game/bubble_help.png'])
        $sound["game/alert.wav"].play(0.2)
      else
        @last_alert += 1
      end
      
      # sometimes look for bunkers to evacuate
      if ($game.frame%60).zero? and bunker = $game.object_space.find {|o| o.is_a?(Bunker) and Gosu::distance(@x, @y, o.x, o.y) <= EvacuateDistance }
        @target = bunker
        @state = :evacuating
        Bubble.new(self, $image['game/bubble_evacuating.png'])
      end
    end
    
    if @state == :following
      @r += -15+rand*30
      
      angle = Gosu::angle(@x, @y, $game.player.x, $game.player.y)
      xd = 0.9*Gosu::offset_x(@r, @speed) + 0.1*Gosu::offset_x(angle, @speed)
      yd = 0.9*Gosu::offset_y(@r, @speed) + 0.1*Gosu::offset_y(angle, @speed)
      @x += xd
      @y += yd
      @r = Gosu::angle(0,0, xd,yd)
      
      # look for bunkers to evacuate
      if bunker = $game.object_space.find {|o| o.is_a?(Bunker) and Gosu::distance(@x, @y, o.x, o.y) <= EvacuateDistance }
        @target = bunker
        @state = :evacuating
        Bubble.new(self, $image['game/bubble_evacuating.png'])
      end
    end
    
    if @state == :evacuating
      if @target
        target_y_off = 8
        if Gosu::distance(@x, @y, @target.x, @target.y+target_y_off) <= 3
          # evacuated!
          unless $game.game_over or $game.won
            $game.rescued += 1
            $sound['game/evacuated.wav'].play(0.5)
          end
          remove
        else
          # walk towards entrance
          @r = Gosu::angle(@x, @y, @target.x, @target.y+target_y_off)
          @x += Gosu::offset_x(@r, @speed)
          @y += Gosu::offset_y(@r, @speed)
        end
      else
        @state = :wandering
      end
    end
    
    if @state == :cheering
      @r = @r-40+rand*80
      @x += Gosu::offset_x(@r, @speed*2)
      @y += Gosu::offset_y(@r, @speed*2)
    end
    
    # "collision" ;)
    $game.object_space.find_all {|o| o.is_a?(House) and Gosu::distance(@x, @y, o.x, o.y) <= 17 }.each do |o|
      angle = Gosu::angle(o.x, o.y, @x, @y)
      @x += Gosu::offset_x(angle, @speed)
      @y += Gosu::offset_y(angle, @speed)
    end
  end
  
  def draw(scroll_x)
    jiggle_r = @r - 30+rand*60
    $image['game/body_walking.png'].draw_rot(@x-scroll_x, @y, ZOrder::People, jiggle_r, 0.5,0.5, 1.0,1.0, @color)
    $image['game/body_walking.png'].draw_rot(@x-scroll_x + 2, @y + 2, ZOrder::People, jiggle_r, 0.5,0.5, 1.0,1.0, 0x88000000)
    $image['game/head.png'].draw_rot(@x-scroll_x, @y, ZOrder::People, @r)
  end
  
  def die
    $game.lost += 1 unless $game.game_over
    Decal.new($image["game/blood_splat#{1+rand(2)}.png"], @x, @y, 2.0)
    Particle.cast($image['game/blood_drop.png'], 15, x,y, 2.5,-1.5+rand*3,1, 10)
    remove
  end
end