class MainMenu < Scene
  TopOffset = 124
  EntrySpacing = 40
  
  def initialize(window)
    super(window)
    
    @menus = {
      'main' => MenuPage.new("", [
        MenuEntry.new("Start Game", proc {@window.scene = Game.new(@window)}),
        MenuEntry.new("Exit", proc {exit})
      ])
    }
    
    @current_menu = @menus['main']
  end
  
  def draw
    $tile['menu/bg.png'].draw(0,0, 0)
    $image['cursor.png'].draw(@window.mouse_x, @window.mouse_y, 2)
    $font['Verdana', 12].draw_rel("v#{EvacuationVersion}", @window.width-2, 2, 1, 1,0)
    
    # draw the actual text
    $font['Verdana', 24].draw_rel(@current_menu.title, @window.width/2.0, 40, 1, 0.5,0.5)
    @current_menu.entries.each_with_index do |entry, i|
      y = TopOffset+(i*EntrySpacing)
      color = 0x88ffffff
      color = 0xffffffff if @window.mouse_y > y-20 and @window.mouse_y < y+20
      $font['Verdana', 24].draw_rel(entry.title, @window.width/2.0, y, 1, 0.5,0.5, 1.0,1.0, color)
    end
    
    @current_menu.title
  end
  
  def button_down(id)
    if id == Gosu::MsLeft
      @current_menu.entries.each_with_index do |entry, i|
        y = TopOffset+(i*EntrySpacing)
        if @window.mouse_y > y-EntrySpacing/2 and @window.mouse_y < y+EntrySpacing/2
          entry.action.call
        end
      end
    end
  end
end

MenuPage = Struct.new("MenuPage", :title, :entries)
MenuEntry = Struct.new("MenuEntry", :title, :action)
