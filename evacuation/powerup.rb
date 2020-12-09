class Powerup
  attr_reader :name, :image, :desc
  
  def initialize
    @name = "Powerup"
    @desc = "This powerup does nothing, really."
    @image = $image['game/powerup.png']
  end
  
  def activate
  end
  
  def self.random
    [TimeoutPowerup, WhistlePowerup, SpeedPowerup].pick.new
  end
end

class TimeoutPowerup < Powerup
  def initialize
    @name = "Timeout"
    @desc = "Freezes the Wall of Death for 3 seconds."
    @image = $image['game/powerup_timeout.png']
  end
  
  def activate
    $sound["game/freeze.wav"].play(0.9)
    $game.awod.frozen = 4*60
  end
end

class WhistlePowerup < Powerup
  def initialize
    @name = "Whistle"
    @desc = "Makes all villagers on the screen follow the player instantly."
    @image = $image['game/powerup_whistle.png']
  end
  
  def activate
    $sound["game/whistle.wav"].play(0.9)
    $game.object_space.find_all {|o| o.is_a?(House)}.each do |o|
      o.empty
    end
    $game.object_space.find_all {|o| o.is_a?(Villager) and o.state == :wandering}.each do |o|
      Bubble.new(o, $image['game/bubble_following.png'])
      o.state = :following 
    end
  end
end

class SpeedPowerup < Powerup
  def initialize
    @name = "Speed"
    @desc = "Gives a speed boost to villagers following the player."
    @image = $image['game/powerup_speed.png']
  end
  
  def activate
    $sound["game/speed.wav"].play(0.7)
    $game.object_space.find_all {|o| o.is_a?(Villager) and (o.state == :following or o.state == :evacuating)}.each do |o|
      o.speed = $game.player.speed
    end
  end
end
