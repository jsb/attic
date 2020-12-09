#
# Evacuation
#
# by jsb (Janis Born)
# <jsb at sapphiredesign dot de>
# for LD14: Advancing Wall of Doom

EvacuationVersion = '1.01'

require 'rubygems'
require 'gosu'

require 'scene.rb'
require 'assets.rb'
require 'main_menu.rb'
require 'game.rb'
require 'game_object.rb'
require 'road.rb'
require 'house.rb'
require 'villager.rb'
require 'awod.rb'
require 'decal.rb'
require 'player_character.rb'
require 'bubble.rb'
require 'bunker.rb'
require 'particle.rb'
require 'message.rb'
require 'powerup.rb'

require 'shader'
require 'shake_effect'
require 'damage_effect'
require 'game_over_effect'

class GameWindow < Gosu::Window
  attr_accessor :scene
  
  def initialize
    full_screen = ARGV.include?("--fullscreen")
    super(640, 480, full_screen)
    $window = self
    
    @scene = Game.new(self) #@scene = MainMenu.new(self)
    
    self.caption = "Evacuation"
  end

  def update
    @scene.update
  end

  def draw
    @scene.draw
  end
  
  def button_down(id)
    @scene.button_down(id)
  end
end

w = GameWindow.new
w.show
