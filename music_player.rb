require "gosu"
require_relative 'song'
require_relative 'collect_songs'
require_relative 'playlist'


""" ZOrder """
module ZOrder
  BACKGROUND, MIDDLE, TOP = *0..2
end


class Button
  WIDTH = 90
  HEIGHT = 50
  FONT_SIZE = 18
  COLOR = Gosu::Color::RED
  attr_accessor :x,:y
  attr_accessor :text, :font_size, :font, :font_color
  attr_accessor :width, :height
  attr_accessor :text_x_pos, :text_y_pos
  attr_accessor :clicked_actions, :hover_actions
  def initialize(text, x, y, clicked_actions=[], hover_actions=[])
    @x = x
    @y = y
    @text = text
    @font_size = self.class::FONT_SIZE
    @font = Gosu::Font.new(@font_size, bold: true)
    @font_color = Gosu::Color::BLACK
    @width = self.class::WIDTH
    @height = self.class::HEIGHT
    @text_x_pos = x+((@width/2)-(@font.text_width(@text)/2))
    @text_y_pos = y+((@height/2)-(@font_size/2))
    @clicked_actions = clicked_actions
    @hover_actions = hover_actions
  end

  def touchedOn?(mx, my)
    puts("-----------> #{@x+@width}-> mx: #{mx}->#{@x} ")
    puts("-----------> #{@y+@height}-> mx: #{my}->#{@y} ")
    if ((mx>=@x and mx<=@x+@width) and (my>=@y and my<=@y+@height)) then
      print("Touched on : mx: #{mx} my: #{my}")
      return true
    end
    return false
  end

  def executeClickedActions()
    print("Clicked Action Execution")
    @clicked_actions.each do |action| action.call() end
  end
  def executeHoverActions()

    @hover_actions.each do |action| action.call() end
  end
  def update()
  end
end

class BinBeyMusicPlayer < Gosu::Window
  MIN_WIDTH = 500
  MIN_HEIGHT = 550
  COLORS = [Gosu::Color::GRAY, Gosu::Color::AQUA, Gosu::Color::GREEN, Gosu::Color::WHITE, Gosu::Color::BLUE, Gosu::Color::CYAN]
  BUTT_BET_SPACE = 20
  VOLUME_FONT_SIZE = 16
  SONG_NAME_FONT_SIZE = 20

  def initialize(width=self.class::MIN_WIDTH, height=self.class::MIN_HEIGHT)
    super(width, height, false)
    self.caption = "BinBey Music Player"
    @width = self.width
    @height = self.height

    @song_name_FONT = Gosu::Font.new(self.class::SONG_NAME_FONT_SIZE, italic: true)
    @volume_FONT = Gosu::Font.new(self.class::VOLUME_FONT_SIZE)

    """Buttons Positions"""
    @buttons_y = @height-(self.class::VOLUME_FONT_SIZE+5*2+Button::HEIGHT)
    @buttons_lx = ->(butt_type){buttons_x_poss()[butt_type]}

    """Song name positions"""
    @song_name_y = @buttons_y/2
    @song_name_lx = ->(song_name){(@width/2)-(song_name.length/2)}

    """Create Play List"""
    @play_list = PlayList.new(*collectSongs())

    """Construct Buttons"""
    @play_pause = true

    @prevButton = Button.new("prev", @buttons_lx.call('prevBX'), @buttons_y)
    @prevButton.clicked_actions <<->(){@play_list.playPrevSong()}

    @playButton = Button.new("play", @buttons_lx.call('playBX'), @buttons_y)
    @playButton.clicked_actions <<->(){
          puts("Inside .....")
          if @play_pause then
            @play_list.play()
            @play_pause=false
            @playButton.text = "pause"
          else
            @play_list.pause()
            @play_pause=true
            @playButton.text = "play"
          end
    }
    @nextButton = Button.new("next", @buttons_lx.call('nextBX'), @buttons_y)
    @nextButton.clicked_actions <<->(){
        @play_list.playNextSong()}

  end

  def draw_buttons()
    [@prevButton, @playButton, @nextButton].each do |button|
      draw_rect(button.x, button.y, button.width, button.height, Button::COLOR, ZOrder::TOP)
      button.font.draw_text(button.text, button.text_x_pos, button.text_y_pos, ZOrder::TOP,1.0,1.0,
        button.font_color)
    end
  end

  def buttons_x_poss()
    fcs = ((@width/2)-([Button::WIDTH*3, self.class::BUTT_BET_SPACE*2].inject{|x,y|x+y}/2))
    prevBX = fcs
    playBX = prevBX+Button::WIDTH+self.class::BUTT_BET_SPACE
    nextBX = playBX+Button::WIDTH+self.class::BUTT_BET_SPACE

    return {'prevBX'=>prevBX, 'playBX'=>playBX, 'nextBX'=>nextBX}
  end

  def draw()
    # draw background with color black
    draw_rect(0, 0, @width, @height, Gosu::Color::WHITE, ZOrder::BACKGROUND)

    # draw buttons
    draw_buttons()

    # draw volume
    tw = @volume_FONT.text_width("Volume: "+(@play_list.volume.round(2)*100).to_i.to_s+"%")
    @volume_FONT.draw_text("Volume: "+(@play_list.volume.round(2)*100).to_i.to_s+"%",
                           (@width/2)-(tw/2),
                           @height-(self.class::VOLUME_FONT_SIZE+10),
                           ZOrder::TOP, 1.0,1.0,Gosu::Color::BLACK)

    # draw name
    tw = @song_name_FONT.text_width(@play_list.current_song.name())
    @song_name_FONT.draw_text(@play_list.current_song.name(),
                              (@width/2)-(tw/2),
                              (@height/2)-(self.class::SONG_NAME_FONT_SIZE/2),
                              ZOrder::TOP, 1.0,1.0,self.class::COLORS.sample())
  end

  def update()
    @play_list.incrVolume() if button_down?(Gosu::KB_UP)
    @play_list.decrVolume() if button_down?(Gosu::KB_DOWN)
    @play_list.playNextSong() if button_down?(Gosu::KB_LEFT)
    @play_list.playPrevSong() if button_down?(Gosu::KB_RIGHT)

    if button_down?(Gosu::MS_LEFT) then
      puts("MOUSE LEFT")
      [@playButton, @prevButton, @nextButton].each do |button|
        puts("mouse_x: #{mouse_x} mouse_y: #{mouse_y}")
        button.executeClickedActions() if button.touchedOn?(mouse_x, mouse_y)
      end
    end
    [@playButton, @prevButton, @nextButton].each do |button|
      button.executeHoverActions() if button.touchedOn?(mouse_x, mouse_y)
    end
  end

  def needs_cursor?();true;end
end



BinBeyMusicPlayer.new.show()
