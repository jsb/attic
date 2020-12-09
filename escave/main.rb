require 'gosu'
require_relative 'source/game.rb'
require_relative 'source/frontend.rb'

class MainWindow < Gosu::Window
  def initialize()
    fullscreen = false
    fullscreen = true if(ARGV[0] == '--fullscreen')
    super(640,480, fullscreen, 18)
    self.caption = "Escave"
  end
  
  def button_down(id)
    $game.button_down(id)
  end
  
  def update()
    $game.update
  end
  
  def draw()
    $game.draw
  end
end

# initialize game globals
$screen = MainWindow.new
$game = Frontend.new

# and off we go.
$screen.show
