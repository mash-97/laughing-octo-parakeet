require_relative 'song'

SONG_DIRS = [
  'songs',
  '.'
]

SONG_TYPES = [
  'mp3',
]

""" Collect Songs """
def collectSongs()
  songs = []
  SONG_DIRS.each do |song_dir|
    dir_path = File.expand_path(song_dir, __dir__)
    patterns = []
    SONG_TYPES.each{ |st| patterns << File.join(dir_path, "**", "*."+st) }
    Dir.glob(patterns).each do |song_file_path|
      songs << Song.new(song_file_path)
    end
  end
  return songs
end


if __FILE__ == $0 then
  puts(collectSongs().collect{|x|x.name()}.to_s)\
end
