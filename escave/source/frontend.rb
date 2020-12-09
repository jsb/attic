class Frontend
  def initialize
    @contents = [
      [MenuEntry.new('Start game', method(:start_game)), MenuEntry.new('Highscores', method(:highscores)), MenuEntry.new('Quit', method(:quit))],
      [MenuEntry.new('Back', method(:main_menu))]
    ]
    @location = 0
    @selected = 0
  end
  
  def button_down(id)
    if(id == Gosu::Button::KbDown)
      @selected = (@selected + 1)%(@contents[@location].size)
    end
    if(id == Gosu::Button::KbUp)
      @selected = (@selected - 1)%(@contents[@location].size)
    end
    
    if(id == Gosu::Button::KbEscape)
      exit
    end
    
    if(id == Gosu::Button::KbReturn or id == Gosu::Button::KbSpace)
      @contents[@location][@selected].activate
    end
  end

  def update
  end
  
  def draw
    Images['media/title.png'].draw(0,0)
    
    # get the menu screen that's currently selected
    menu = @contents[@location]
    menu.each_with_index do |item, i|
      if i == @selected
        item.draw_selected(64+i*48)
      else
        item.draw(64+i*48)
      end
    end
  end
  
  # menu methods
  def main_menu
    @location = 0
    @selected = 0
  end
  
  def start_game
    $game = Game.new
  end
  
  def highscores
    highscore_file = File.readlines('media/highscores.txt')
    highscores = highscore_file.collect {|line| if(line =~ /(\d+)/) then $1.to_i else nil end}.compact.sort.reverse[0...5]
    
    @contents[1] = [MenuEntry.new('Back', method(:main_menu))]
    highscores.each do |highscore|
      @contents[1] << MenuEntry.new(highscore.to_s + ' m', method(:nothing))
    end
    
    @location = 1
    @selected = 0
  end
  
  def quit
    exit
  end
  
  def nothing
  end
end

class MenuEntry
  attr_reader :caption, :method
  def initialize(caption, method)
    @caption = caption
    @method = method
    @font = Gosu::Font.new($screen, Gosu::default_font_name, 36)
  end
  
  def draw(y=0.0)
    @font.draw_rel(@caption, 640/2.0, y, 0, 0.5,0.5, 1,1, 0xffcccccc)
  end
  
  def draw_selected(y=0.0)
    @font.draw_rel(@caption, 640/2.0, y, 0, 0.5,0.5, 1.1,1.1, 0xff888888)
  end
  
  def activate
    @method.call
  end
end
