require_relative 'song'
require_relative 'collect_songs'


class PlayList
  VOLUME_STEP = 0.01
  VOLUME_RANGE = (0.0..1.0)
  class NoSongInTheList < Exception
    def initialize(msg="The playlist is empty!")
      super(msg)
    end
  end

  attr_accessor :songs
  attr_accessor :current_song
  attr_accessor :volume

  def initialize(*songs)
    @songs = songs
    build_doubly_chain()
    @volume = 1.0
    @current_song = @songs.first
  end

  def build_doubly_chain()
    return nil if @songs.empty?
    @songs.inject do |x,y|
      x.set_next_song(y) if x!=nil
      y
    end
    @songs.last.set_next_song(@songs.first)
  end

  def addSong(song)
    @songs.last.set_next_song(song)
    song.set_next_song(@songs.first)
    @songs << song
  end

  def incrVolume()
    @volume += self.class::VOLUME_STEP if self.class::VOLUME_RANGE.include?(@volume+self.class::VOLUME_STEP)
    @current_song.volume = @volume
  end

  def decrVolume()
    @volume -= self.class::VOLUME_STEP if self.class::VOLUME_RANGE.include?(@volume-self.class::VOLUME_STEP)
    @current_song.volume = @volume
  end

  def play()
    raise(NoSongInTheList) if @songs.empty?

    @current_song = @songs.first if @current_song==nil
    @current_song.volume =  @volume
    @current_song.play()
  end

  def playNextSong()
    raise(NoSongInTheList) if @songs.empty?

    if @current_song==nil then
      @current_song = @songs.first
    else
      @current_song.stop()
      @current_song = @current_song.next_song
    end
    @current_song.volume = @volume
    @current_song.play()
  end

  def playPrevSong()
    raise(NoSongInTheList) if @songs.empty?

    if @current_song==nil then
      @current_song = @songs.first
    else
      @current_song.stop()
      @current_song = @current_song.prev_song
    end
    @current_song.volume = @volume
    @current_song.play()
  end

  def pause()
    raise(NoSongInTheList) if @songs.empty?
    @current_song = @songs.first if @current_song==nil
    @current_song.pause()
  end
end


if __FILE__==$0 then
  class W < Gosu::Window
    attr_accessor :p
    def initialize()
      @width = 300
      @height = 300
      super(300, 300)
      @songs = collectSongs()
      @bs = @songs.last
      @songs.delete(@bs)
      @p = PlayList.new(*@songs)
      @p.play()
      @font = Gosu::Font.new(16, bold: true)
    end

    def draw()
      text_w = @font.text_width(@p.current_song.name())

      @font.draw_text(@p.current_song.name(),
                      (@width/2)-(text_w/2),
                      (@height/2)-(@font.height/2), 2)
    end

    def update()
      @p.pause() if button_down?(Gosu::MS_RIGHT)
      @p.play() if button_down?(Gosu::MS_LEFT)
      @p.playNextSong() if button_down?(Gosu::KB_LEFT)
      @p.playPrevSong() if button_down?(Gosu::KB_RIGHT)
      @p.addSong(@bs) if button_down?(Gosu::KB_A)
      @p.incrVolume() if button_down?(Gosu::KB_UP)
      @p.decrVolume() if button_down?(Gosu::KB_DOWN)
      @p.current_song.volume = 0.0 if button_down?(Gosu::KB_M)

    end

  end
  W.new.show()
  # @p = PlayList.new(*collectSongs())
  # f = @p.songs.first
  # c = f.next_song
  # while c!=f do
  #   puts("Song: #{c.name} next: #{c.next_song.name} prev: #{c.prev_song.name}")
  #   c = c.next_song
  # end
end
