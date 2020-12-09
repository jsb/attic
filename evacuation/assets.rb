class Array
  def pick
    self[rand(size)]
  end
  
  def shuffle
    sort_by {rand}
  end
end

module Comparable
  def bound_by(min, max)
    return min if self < min
    return max if self > max
    self
  end
end

class FPSCounter
  attr_reader :fps
  
  def initialize
    @current_second = Gosu::milliseconds / 1000
    @accum_fps = 0
    @fps = 0
  end
  
  def register_tick
    @accum_fps += 1
    current_second = Gosu::milliseconds / 1000
    if current_second != @current_second
      @current_second = current_second
      @fps = @accum_fps
      @accum_fps = 0
    end
  end
end

module ZOrder
  Background, Landscape, Roads, Bunkers, Decals, Particles, Shadows, Glow, People, Scenery, WallShadow, Wall, Overlay, HUD, Cursor = *((0...15).to_a)
end

$image = Hash.new do |hash, fn|
  hash[fn] = Gosu::Image.new($window, 'media/'+fn, false)
end
$tile = Hash.new do |hash, fn|
  hash[fn] = Gosu::Image.new($window, 'media/'+fn, true)
end
$sound = Hash.new do |hash, fn|
  hash[fn] = Gosu::Sample.new($window, 'media/'+fn)
end
class FontIndexer
  def initialize
    @hash = {}
  end
  def [](name, size)
    @hash[[name, size]] or @hash[[name, size]] = Gosu::Font.new($window, name, size)
  end
end
$font = FontIndexer.new

