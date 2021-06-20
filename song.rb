require 'gosu'

class Song < Gosu::Song
  attr_accessor :prev_song
  attr_accessor :next_song
  
  def initialize(file_path, next_song=nil, prev_song=nil)
    @file_path = file_path
    @next_song = next_song
    @prev_song = prev_song
    super(file_path)
  end

  def name()
    return File.basename(@file_path)
  end

  def set_next_song(next_song)
    next_song.prev_song = self
    @next_song = next_song
  end
  def set_prev_song(prev_song)
    prev_song.next_song = self
    @prev_song = prev_song
  end
end
