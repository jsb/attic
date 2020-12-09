# two helper classes to access files

class Images
  def Images.[](name)
    @@images = Hash.new unless defined?(@@images)
    if @@images[name]
      @@images[name]
    else
      @@images[name] = Gosu::Image.new($screen, name, false)
    end
  end
end

class Tiles
  def Tiles.[](name)
    @@tiles = Hash.new unless defined?(@@tiles)
    if @@tiles[name]
      @@tiles[name]
    else
      @@tiles[name] = Gosu::Image.load_tiles($screen, name, 32,32, true)
    end
  end
end

class Sounds
  def Sounds.[](name)
    @@sounds = Hash.new unless defined?(@@sounds)
    if @@sounds[name]
      @@sounds[name]
    else
      @@sounds[name] = Gosu::Sample.new($screen, name)
    end
  end
end

# game logic classes go here

module ZOrder
  Sky, Background, Landscape, Items, Player, Particles, HUD = (0...7).to_a
end

class Game
  attr_accessor :object_space, :map, :player, :scroll_x, :scroll_speed, :gravity
  def initialize
    @object_space = []
    @map = Map.new
    @player = Player.new(600,200)
    @background = Background.new
    @hud = HUD.new
    @scroll_x = 0.0
    @scroll_speed = 1.5
    @gravity = 1.0
    @paused = false
  end
  
  def button_down(id)
    if id == Gosu::Button::KbReturn
      $game = Game.new
    end
    
    if id == Gosu::Button::KbEscape
      $game = Frontend.new
    end
    
    if id == Gosu::Button::KbSpace
      @paused = !@paused
    end
  end
  
  def meters
    ($game.player.x/48).to_i
  end
  
  def update
    return nil if @paused
    @scroll_speed = scroll_speed + 0.001 if @scroll_speed < 5.0 and @player.alive
    Particle.new($game.scroll_x,rand*480, 'media/fireball.png', rand*$game.scroll_speed,rand*-2.0, rand*360, 0, 0.0, 0.2)
    Fireball.new(@scroll_x, rand*480, rand*10.0, rand*-20.0) if(rand(92) == 0)
    
    @scroll_x += @scroll_speed
    @player.jump if($screen.button_down?(Gosu::Button::KbUp))
    @player.left if($screen.button_down?(Gosu::Button::KbLeft))
    @player.right if($screen.button_down?(Gosu::Button::KbRight))
    
    
    #@scroll_speed += 0.25 if($screen.button_down?(Gosu::Button::KbPageUp))
    #@scroll_speed -= 0.25 if($screen.button_down?(Gosu::Button::KbPageDown))
    
    @background.update(@scroll_x)
    @map.update(@scroll_x)
    @player.update(@scroll_x)
    @hud.update
    @object_space.reject! do |obj|
      !obj.update(@scroll_x)
    end
  end
  
  def draw
    @background.draw(@scroll_x)
    @map.draw(@scroll_x)
    @player.draw(@scroll_x)
    @hud.draw
    @object_space.each do |obj|
      obj.draw(@scroll_x)
    end
  end
end

class Background
  def initialize()
  end
  
  def update(scrollx=0.0)
  end
  
  def draw(scrollx=0.0)
    color = Gosu::Color.new(255, 200+Math::sin(scrollx/50.0)*55,200+Math::sin(scrollx/50.0)*55,200+Math::sin(scrollx/50.0)*55)
    Images['media/cave.png'].draw((-(scrollx)/2.0)%640-640, 0.0, ZOrder::Background, 1,1, color)
    Images['media/cave.png'].draw((-(scrollx)/2.0)%640, 0.0, ZOrder::Background, 1,1, color)
    
    Images['media/cave_layer1.png'].draw((-(scrollx)/1.7)%640-640, 0.0, ZOrder::Background)
    Images['media/cave_layer1.png'].draw((-(scrollx)/1.7)%640, 0.0, ZOrder::Background)
    
    Images['media/cave_layer2.png'].draw((-(scrollx)/1.3)%640-640, 0.0, ZOrder::Background)
    Images['media/cave_layer2.png'].draw((-(scrollx)/1.3)%640, 0.0, ZOrder::Background)
  end
end

class Map
  attr_reader :map_solid
  def initialize(width=21, height=15)
    @width = width
    @height = height
    
    @scroll_offset = 0.0
    
    @tiles = Tiles['media/landscape.png']
    
    # the map is saves as an array of colums
    @map = []
    @map_solid = []
    @traps = []
    
    @width.times do |x|
      column = []
      solid_column = []
      col_height = 1+rand(2)
      
      (@height-col_height).times do |y|
        column << 0
        solid_column << false
      end
      
      column << 4+rand(2)
      solid_column << true
      
      (@height-(col_height-1)).times do |y|
        column << 1+rand(3)
        solid_column << true
      end
      @map << column
      @map_solid << solid_column
      @traps << nil
    end
    
    #$game.object_space << self
  end
  
  def update(scrollx = 0.0)
    if(scrollx > @scroll_offset)
      last_col_height = 0
      i = 15
      while(@map_solid[-1][i-=1])
        last_col_height += 1
      end
      
      column = [0]*15
      solid_column = [false]*15
      
      col_height = last_col_height -2+rand(5)
      col_height = 1 if(rand(10) == 0)
      
      col_height = 13 if(col_height > 13)
      col_height = 1 if(col_height < 1)
      
      (col_height-1).times do |i|
        column[14-i] = 1+rand(3)
        solid_column[14-i] = true
      end
      
      column[15-col_height] = 4+rand(2)
      solid_column[15-col_height] = true
      
      @map << column
      @map_solid << solid_column
      @width+=1
      
      @scroll_offset += 32.0
      
      trap = nil
      
      unless(trap)
        if((col_height == last_col_height || col_height == 1) && rand(4) == 0)
          unless(@traps[-1].class == Trap)
            trap = Trap.new(640+@scroll_offset + 16, 480 - (col_height+1)*32 + 16)
          end
        end
      end
      unless(trap)
        trap = FireFountain.new(640+@scroll_offset + 16, 480 - (col_height)*32) if(rand(24)==0)
      end
      unless(trap)
        trap = Mole.new(640+@scroll_offset + 16, 480 - (col_height)*32) if(rand(24)==0)
      end
      unless(trap)
        if(col_height < 10)
          trap = Stalagtite.new(640+@scroll_offset + 16, 0) if(rand(4)==0)
        end
      end
      unless(trap)
        trap = CoilSpring.new(640+@scroll_offset + 16, 480 - (col_height+1)*32 + 16) if(rand(24)==0)
      end
      
      @traps << trap
    end
    return true
  end
  
  def draw(scrollx = 0.0)
    (scrollx.to_i/32).upto(@width-1) do |x|
      @height.times do |y|
        @tiles[@map[x][y]].draw(x*32.0 - scrollx, y*32.0, ZOrder::Landscape)
      end
    end
  end
end

class Thing
  attr_reader :x, :y
  def initialize(x, y, image_name)
    @x = x
    @y = y
    @flipfactor = 1.0
    @image_name = image_name
    
    $game.object_space << self
  end
  
  def update(scrollx = 0.0)
    return true
  end
  
  def draw(scrollx = 0.0)
    Images[@image_name].draw(@x - scrollx - @flipfactor*Images[@image_name].width/2.0, @y - Images[@image_name].height/2.0, ZOrder::Items, @flipfactor)
  end
end

class Particle
  attr_accessor :x,:y, :graphics_name, :xdir,:ydir, :r, :rdir, :scale, :growth, :fadeout
  def initialize(x,y, graphics_name, xdir=0.0,ydir=0.0, r=0.0, rdir=0.0, scale=1.0, growth=0.0, fadeout=5, blitmode=:additive)
    @x = x
    @y = y
    @graphics_name = graphics_name
    @image_index = rand(Tiles[@graphics_name].size)
    @xdir = xdir
    @ydir = ydir
    @r = r
    @rdir = rdir
    @scale = scale
    @growth = growth
    @alpha = 255
    @color = Gosu::Color.new(255,255,255, @alpha)
    @fadeout = fadeout
    @blitmode = blitmode
    
    $game.object_space << self
  end
  
  def update(scrollx=0.0)
    @x += @xdir
    @y += @ydir
    @r += @rdir
    @scale += @growth
    @alpha -= @fadeout
    @color.alpha = @alpha
    
    return false if(@y > 480)
    return false if(@y < 0)
    return false if(@scale <= 0)
    return false if(@alpha <= 0)
    
    return true
  end
  
  def draw(scrollx=0.0)
    Tiles[@graphics_name][@image_index].draw_rot(@x-scrollx, @y, ZOrder::Particles, @r, 0.5,0.5, @scale,@scale, @color, @blitmode)
  end
end

class Moveable < Thing
  def initialize(x, y, image_name, xdir=0.0, ydir=0.0, box_width=1.0,box_height=1.0)
    super(x,y, image_name)
    
    @xdir = xdir
    @ydir = ydir
    
    @box_width = Images[@image_name].width*box_width
    @box_height = Images[@image_name].height*box_height
    
    @movement_speed = 1.0
  end
  
  def update(scrollx = 0.0)
    @ydir += $game.gravity*@movement_speed
    
    # collision detection
    
    testx = @x+@xdir*@movement_speed
    testy = @y+@ydir*@movement_speed
    
    if(testx > scrollx+640)
      @xdir = 0
      hit
    end
    
    if(@xdir < 0)
      mapx = (testx - @box_width/2.0).to_i/32
      mapy = (testy).to_i/32
      if($game.map.map_solid[mapx][mapy])
        @x = (mapx+1)*32.0 + @box_width/2.0
        hit
        @xdir = 0.0
      else
        @x += @xdir*@movement_speed
      end
    end
    if(@xdir > 0)
      mapx = (testx + @box_width/2.0).to_i/32
      mapy = (testy).to_i/32
      if($game.map.map_solid[mapx][mapy])
        @x = (mapx)*32.0 - @box_width/2.0
        hit
        @xdir = 0.0
      else
        @x += @xdir*@movement_speed
      end
    end
    if(@ydir < 0)
      mapx = (testx).to_i/32
      mapy = (testy - @box_height/2.0).to_i/32
      if($game.map.map_solid[mapx][mapy])
        @y = (mapy+1)*32.0 + @box_height/2.0
        hit
        @ydir = 0.0
      else
        @y += @ydir*@movement_speed
      end
    end
    if(@ydir > 0)
      mapx = (testx).to_i/32
      mapy = (testy + @box_height/2.0).to_i/32
      if($game.map.map_solid[mapx][mapy])
        @y = (mapy)*32.0 - @box_height/2.0
        hit
        @ydir = 0.0
      else
        @y += @ydir*@movement_speed
      end
    end
    
    super
  end
  
  def hit
  end
end

class Player < Moveable
  attr_reader :energy, :alive
  attr_accessor :xdir, :ydir
  def initialize(x,y)
    @x = x
    @y = y
    @xdir = 0.0
    @ydir = 0.0
    @flipfactor = 1.0
    @movement_speed = 1.0
    
    @energy = 1.0
    
    @graphics = Gosu::Image.load_tiles($screen, 'media/player_tiles.bmp', 16, 32, false)
    @box_width = @graphics[0].width
    @box_height = @graphics[0].height
    @anim_phase = 0
    @alive = true
  end
  
  def update(scrollx=0.0)
    damage(1.0) if @x <= scrollx
    if(bottom_contact?)
      @xdir *= 0.5
      @anim_phase = 0 if (@anim_phase >= 6) or (@xdir.to_i == 0)
    else
      if (@anim_phase < 6)
        @anim_phase = 6
      else
        @anim_phase += 1 if(@anim_phase < 9)
      end
    end
    super
  end
  
  def bottom_contact?
    $game.map.map_solid[(@x).to_i/32][(@y+@box_height/2.0).to_i/32]
  end
  
  def left
    return nil unless @alive
    if bottom_contact?
      @anim_phase = (@anim_phase+1)%6
      @flipfactor = -1.0
      @xdir = -7.5
    else
      @xdir -= 2.5 if @xdir > -5.0
    end
  end
  def right
    return nil unless @alive
    if bottom_contact?
      @anim_phase = (@anim_phase+1)%6
      @flipfactor = +1.0
      @xdir = +7.5
    else
      @xdir += 2.5 if @xdir < 5.0
    end
  end
  
  def jump
    return nil unless @alive
    if bottom_contact?
      @ydir = -12.0
      @anim_phase = 6
    end
  end
  
  def damage(gain)
    return nil if gain <= 0
    return nil unless @alive
    
    5.times do
      Particle.new(@x,@y, 'media/blood.bmp', -2.0+rand*4.0,-2.0+rand*4.0, rand*360, 0, 1.0, 0.05, 10, :default)
    end
    @energy -= gain
    if(@energy <= 0)
      kill
    else
      Sounds["media/ouch#{1+rand(3)}.wav"].play_pan(((@x-$game.scroll_x)-320.0)/320.0, 1.0, 0.9+rand*0.2)
    end
  end
  
  def kill
    return nil unless @alive
    Sounds['media/die.wav'].play_pan(((@x-$game.scroll_x)-320.0)/320.0, 1.0, 0.9+rand*0.2)
    20.times do
      Particle.new(@x,@y, 'media/blood.bmp', -2.0+rand*4.0,-2.0+rand*4.0, rand*360, 0, 1.0, 0.05, 10, :default)
    end
    @alive = false
    $game.scroll_speed = 0.0
    
    # save highscore
    highscore_file = File.readlines('media/highscores.txt')
    highscores = highscore_file.collect {|line| if(line =~ /(\d+)/) then $1.to_i else nil end}.push($game.meters).compact.sort.reverse
    rank = highscores.index($game.meters)
    f = File.open('media/highscores.txt', 'w')
      f.puts highscores
    f.close
    
    GameOver.new.rank = rank
  end
  
  def draw(scrollx = 0.0)
    if @alive
      @graphics[@anim_phase].draw(@x - scrollx - @flipfactor*@graphics[@anim_phase].width/2.0, @y - @graphics[@anim_phase].height/2.0, ZOrder::Items, @flipfactor)
    end  
  end
end

class GameOver
  attr_accessor :rank
  def initialize
    @gameover = Gosu::Font.new($screen, Gosu::default_font_name, 48)
    @instructions = Gosu::Font.new($screen, Gosu::default_font_name, 18)
    @rank = "?"
    $game.object_space << self
  end
  
  def update(scrollx=0.0)
    return true
  end
  
  def draw(scrollx=0.0)
    @gameover.draw_rel("Game Over", 640/2.0, 480/2.0, ZOrder::HUD, 0.5,0.5)
    @instructions.draw_rel("You managed to run #{$game.meters} meters.", 640/2.0, 480/2.0+40, ZOrder::HUD, 0.5,0.5)
    @instructions.draw_rel("Press RETURN to restart game, ESC to return to main menu.", 640/2.0, 480-20, ZOrder::HUD, 0.5,0.5)
  end
end

class HUD
  def initialize
    @font = Gosu::Font.new($screen, Gosu::default_font_name, 16)
  end
  
  def update
  end
  
  def draw
    @font.draw("#{$game.meters} meters", 16,48, ZOrder::HUD)
    5.times do |i|
      Images['media/heart.png'].draw_rot(24+i*32, 24, ZOrder::HUD, 0, 0.5,0.5, 1,1, 0xAA000000)
    end
    
    energy = $game.player.energy
    
    5.times do |i|
      energy_before = energy
      energy -= 1.0/5.0
      energy = 0 if(energy < 0)
      heart_size = (energy_before-energy)*5
      heart_size = 1 if heart_size > 1
      heart_size = 0 if heart_size < 0
      Images['media/heart.png'].draw_rot(24+i*32, 24, ZOrder::HUD, 0, 0.5,0.5, heart_size,heart_size)
    end
  end
end

class Trap < Thing
  def initialize(x,y)
    super(x,y, 'media/trap.bmp')
  end
  
  def update(scrollx=0.0)
    return false if(@x < scrollx)
    return true if($game.player.x < @x - 10.0)
    return true if($game.player.x > @x + 10.0)
    return true if($game.player.y < @y - 10.0)
    return true if($game.player.y > @y + 10.0)
    return blow_up
  end
  
  def blow_up
    4.times do |i|
      Particle.new(@x,@y, 'media/fireball.png', -2.5+rand*5.0,-2.5+rand*5.0, rand*360, -0.5+rand*1.0, 1.5, 0.2)
    end
    
    Sounds['media/boom.wav'].play_pan(((@x-$game.scroll_x)-320.0)/320.0, 1.0, 0.8+rand*0.4)
    
    $game.player.damage(0.6)
    
    return false
  end
end

class FireFountain
  def initialize(x,y)
    @x = x
    @y = y
    @age = 0
    $game.object_space << self
  end
  
  def update(scrollx=0.0)
    return false if(@x < scrollx)
    
    if(@age%120) < 60
      Particle.new(@x,@y, 'media/fireball.png', 0.0,-10.0+rand*1.0, rand*360, 0, 0.5, 0.05+rand*0.05, 10)
      
      if($game.player.x > @x-5 and $game.player.x < @x+5 and $game.player.y > @y-120 and $game.player.y < @y)
        $game.player.damage(0.1)
        Sounds['media/burn.wav'].play_pan(((@x-$game.scroll_x)-320.0)/320.0, 1.0, 0.8+rand*0.4)
      end
    end
    if(@age%120 == 0)
      Sounds['media/firefountain.wav'].play_pan(((@x-$game.scroll_x)-320.0)/320.0, 1.0, 0.9+rand*0.2)
    end
    
    @age += 1
    return true
  end
  
  def draw(xscroll=0.0)
    Images['media/firefountain.bmp'].draw_rot(@x-xscroll,@y, ZOrder::Items)
  end
end

class Mole
  def initialize(x,y)
    @x = x
    @y = y
    @age = 0
    @xscale = -1.0
    @xyratio = 0.1
    
    $game.object_space << self
  end
  
  def update(scrollx=0.0)
    return false if(@x < scrollx)
    
    @age += 1
    
    @xyratio = (0.1*1.0 + 0.9*@xyratio)
    
    @xscale = -1.0 if($game.player.x < @x)
    @xscale = +1.0 if($game.player.x > @x)
    
    if(@age%58 == 0)
      @xyratio = 2.0
      Sounds['media/mole_throw.wav'].play_pan(((@x-$game.scroll_x)-320.0)/320.0, 1.0, 1.2+rand*0.2)
      EarthChunk.new(@x, @y-10, ($game.player.x-@x)/10.0 -5+rand*10, [($game.player.y-@y)/5.0 -($game.player.x-@x)/10.0 -5+rand*10, -20].max)
    end
    return true
  end
  
  def draw(xscroll=0.0)
    Images['media/mole.bmp'].draw_rot(@x-xscroll,@y, ZOrder::Items, 0, 0.5,0.5, @xscale/@xyratio,1*@xyratio)
  end
end

class EarthChunk < Moveable
  def initialize(x,y, xdir,ydir)
    super(x,y, 'media/earthchunk.bmp', xdir,ydir)
    @movement_speed = 0.4
  end
  
  def update(scrollx=0.0)
    if(@x > $game.player.x-10 and @x < $game.player.x+10 and @y > $game.player.y-10 and @y < $game.player.y+10)
      $game.player.damage(0.25)
      hit
    end
    super
  end
  
  def hit
    5.times do
      Particle.new(@x,@y, 'media/earth_particle.bmp', -0.5+rand*1.0,-0.5+rand*1.0, rand*360, 0, rand*1.0, 0.01, 10, :default)
    end
    Sounds['media/chunk_hit.wav'].play_pan(((@x-$game.scroll_x)-320.0)/320.0, 1.0, 0.9+rand*0.2)
    $game.object_space.delete(self)
  end
end

class Fireball
  def initialize(x,y, xdir,ydir)
    @x = x
    @y = y
    @xdir = xdir
    @ydir = ydir
    
    $game.object_space << self
  end
  
  def update(scrollx=0.0)
    return false if @y > 480
    
    Particle.new(@x,@y, 'media/fireball.png', 0.0,0.0, rand*360, 0, 0.5, 0.1, 20)
    
    @ydir += $game.gravity/5.0
    @x += @xdir
    @y += @ydir
    
    if(@x > $game.player.x-12 and @x < $game.player.x+12 and @y > $game.player.y-12 and @y < $game.player.y+12)
      $game.player.damage(0.3)
      Sounds['media/burn.wav'].play_pan(((@x-$game.scroll_x)-320.0)/320.0, 1.0, 0.9+rand*0.2)
      return false
    end
    
    return true
  end
  
  def draw(scrollx=0.0)
    Images['media/light.png'].draw_rot(@x-scrollx,@y, ZOrder::Particles, rand*360, 0.5,0.5, 10,10, 0x22ffff00, :additive)
  end
end

class Stalagtite < Thing
  def initialize(x, y=0.0)
    @trap = false
    @trap = true if rand(2) == 0
    super(x,y, 'media/stalactite.png')
  end
  
  def update(scrollx=0.0)
    return false if @x < scrollx
    
    if(@trap)
      if($game.player.x > @x - 20 and $game.player.x < @x + 10)
        LooseStalagtite.new(@x,@y+1)
        return false
      end
    end
    
    super
  end
end

class LooseStalagtite < Moveable
  def initialize(x, y=0.0)
    super(x,y, 'media/stalactite.png')
  end
  
  def update(scrollx=0.0)
    return false if @x < scrollx
    
    if($game.player.x > @x - 10 and $game.player.x < @x + 10 and $game.player.y > @y - 10 and $game.player.y < @y + 30)
      $game.player.damage(0.4)
      hit
      return false
    end
    
    super
  end
  
  def hit
    5.times do
      Particle.new(@x,@y+32, 'media/earth_particle.bmp', -0.5+rand*1.0,-rand*1.0, rand*360, 0, rand*1.0, 0.01, 10, :default)
    end
    Sounds['media/chunk_hit.wav'].play_pan(((@x-$game.scroll_x)-320.0)/320.0, 1.0, 0.9+rand*0.2)
    $game.object_space.delete(self)
  end
end

class CoilSpring < Thing
  def initialize(x, y=0.0)
    super(x,y, 'media/coil_spring.bmp')
  end
  
  def update(scrollx=0.0)
    return false if(@x < scrollx)
    return true if($game.player.x < @x - 10.0)
    return true if($game.player.x > @x + 10.0)
    return true if($game.player.y < @y - 20.0)
    return true if($game.player.y > @y + 20.0)
    return true if($game.player.ydir <= 0.0)
    
    Sounds['media/boing.wav'].play_pan(((@x-$game.scroll_x)-320.0)/320.0, 1.0, 0.9+rand*0.2)
    $game.player.ydir = -1.5*($game.player.ydir.abs)
    
    super
  end
end
