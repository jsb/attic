#
# Evacuation
#
# by jsb (Janis Born)
# <jsb at sapphiredesign dot de>
# for LD14: Advancing Wall of Doom

EvacuationVersion = '1.01'

require 'rubygems'
require 'gosu'

require_relative 'scene.rb'
require_relative 'assets.rb'
require_relative 'main_menu.rb'
require_relative 'game.rb'
require_relative 'game_object.rb'
require_relative 'road.rb'
require_relative 'house.rb'
require_relative 'villager.rb'
require_relative 'awod.rb'
require_relative 'decal.rb'
require_relative 'player_character.rb'
require_relative 'bubble.rb'
require_relative 'bunker.rb'
require_relative 'particle.rb'
require_relative 'message.rb'
require_relative 'powerup.rb'

require_relative 'shader.rb'
require_relative 'shake_effect.rb'
require_relative 'damage_effect.rb'
require_relative 'game_over_effect.rb'

class GameWindow < Gosu::Window
  attr_accessor :scene
  
  def initialize
    full_screen = ARGV.include?("--fullscreen")
    super(640, 480, full_screen)
    $window = self
    
    @scene = MainMenu.new(self)
    
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
