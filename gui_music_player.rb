require 'rubygems'
require 'gosu'

TOP_COLOR = Gosu::Color.rgb(255, 192, 203)
BOTTOM_COLOR = Gosu::Color.rgb(250, 128, 114)
ALBUMS_COLOR = Gosu::Color.rgb(235, 107, 107)
BACKGROUND_ALBUM = Gosu::Color.rgb(255, 100, 100)
BACKGROUND_ALBUMS = Gosu::Color.rgb(255, 193, 204)
BACKGROUND_TEXT = Gosu::Color.rgb(0,0,0)
SCREEN_WIDTH = 1200
SCREEN_HEIGHT = 900
RATIO = 0.666
VOLUME_COLOR = Gosu::Color.new(0xFFD5DAF2)
module ZOrder
  BACKGROUND, MIDDLE, TOP = *0..2
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end
$genre_names = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

class ArtWork
  attr_accessor :bmp, :dim
  def initialize(file, leftX, topY)
    @bmp = Gosu::Image.new(file)
    @dim = Dimension.new(leftX, topY, leftX + (@bmp.width * RATIO), topY + (@bmp.height * RATIO))
  end
end

class Album
  attr_accessor :artist, :title, :tracks, :artwork, :file, :year, :genre
  def initialize(artist, title, year, genre, artwork, tracks, file)
    @artist = artist
    @title = title
    @year = year
    @genre = genre
    @artwork = artwork
    @tracks = tracks
    @file = file
  end
end

class Track
  attr_accessor :name, :location, :dim
  def initialize(name, location, dim)
    @name = name
    @location = location
    @dim = dim
  end
end

class Dimension
  attr_accessor :leftX, :topY, :rightX, :bottomY
  def initialize(leftX, topY, rightX, bottomY)
    @leftX = leftX
    @topY = topY
    @rightX = rightX
    @bottomY = bottomY
  end
end

class All
  attr_accessor :name, :location
  def initialize(name, location)
    @name = name
    @location = location
  end
end

class MusicPlayerMain < Gosu::Window
  def initialize
    super SCREEN_WIDTH, SCREEN_HEIGHT
    self.caption = "Music Player"
    @track_font = Gosu::Font.new(25)
		@track_font1 = Gosu::Font.new(40)
    @track_header = Gosu::Font.new(55)
		@track_header1 = Gosu::Font.new(45)
    @albums = read_albums()
		@track_playing = -1
		@track_per_page = 3
		@current_page = 0
		@change_volume = false
		@pause = false
    @current_genre = nil
		@current_album = nil
		@volume = 1
    @current_state = :main
		@playlist = []
		@playlist_click = false
  	@selected_track = nil

    # Main labels
    @labels = {
      all_albums: { label: "All albums", x: 515, y: 210 },
      year: { label: "Year", x: 565, y: 360 },
      genre: { label: "Genre", x: 555, y: 510 },
			playlist: { label: "Playlist", x: 550, y: 660 }
    }

    # Year sorting labels
    @year_labels = {
      oldest_to_newest: { label: "Oldest to Newest", x: 440, y: 250 },
      newest_to_oldest: { label: "Newest to Oldest", x: 440, y: 400 },
      back: { label: "Back", x: 570, y: 550 }
    }

    # Genre labels
    @genre_labels = {
      Genre::POP => { label: "Pop", x: 580, y: 100 },
      Genre::CLASSIC => { label: "Classic", x: 550, y: 250 },
      Genre::JAZZ => { label: "Jazz", x: 580, y: 400 },
      Genre::ROCK => { label: "Rock", x: 570, y: 550 },
      back: { label: "Back", x: 570, y: 700 }
    }
  end

  def read_albums
    music_file = File.new('albums.txt', 'r')
    albums = []
    count = music_file.gets.chomp.to_i
    i = 0
    while i < count
      album = read_album(music_file)
      albums << album
      i += 1
    end
    music_file.close
    return albums
  end

  def read_album(music_file)
    title = music_file.gets.chomp
    artist = music_file.gets.chomp
    year = music_file.gets.chomp
    genre = music_file.gets.chomp.to_i
    file = music_file.gets.chomp
    artwork = ArtWork.new(file, 0, 0)
    tracks = read_tracks(music_file)
    album = Album.new(artist, title, year, genre, artwork, tracks, file)
    return album
  end

  def read_tracks(music_file)
    count = music_file.gets.chomp.to_i
    tracks = []
    i = 0
    while i < count
      track = read_track(music_file)
      tracks << track
      i += 1
    end
    return tracks
  end

  def read_track(music_file)
    track_name = music_file.gets.chomp
    track_location = music_file.gets.chomp
    dim = Dimension.new(0, 0, 0, 0)
    track = Track.new(track_name, track_location, dim)
    return track
  end

  def sorting_ascending(albums)
    sorted_albums = albums.sort_by { |album| album.year.chomp.to_i }
    return sorted_albums
  end

  def sorting_descending(albums)
    sorted_albums = albums.sort_by { |album| -album.year.chomp.to_i }
    return sorted_albums
  end

  def sorting_genre(albums)
    sorted_albums = albums.sort_by { |album| album.genre.to_i }
    return sorted_albums
  end

	#------------------>Play song<--------------------------
  def playTrack(location)
    @song = Gosu::Song.new(location)
    @song.play(false)
		@song_finished = false
		@song.volume = @volume
  end
#---------------------------------->Draw system<--------------------------------------
	def draw_mouse
		mouse_x_text = "Mouse X: #{mouse_x.to_i}"
		mouse_y_text = "Mouse Y: #{mouse_y.to_i}"
		@track_font.draw_text(mouse_x_text, 50, 840, ZOrder::MIDDLE, 1.0, 1.0, Gosu::Color::BLACK)
		@track_font.draw_text(mouse_y_text, 50, 870, ZOrder::MIDDLE, 1.0, 1.0, Gosu::Color::BLACK)
	end


  def draw_background
		draw_quad(0, 0, TOP_COLOR, SCREEN_WIDTH, 0, TOP_COLOR, 0, SCREEN_HEIGHT, BOTTOM_COLOR, SCREEN_WIDTH, SCREEN_HEIGHT, BOTTOM_COLOR, ZOrder::BACKGROUND)
	end

  def draw_main_labels
		keys = @labels.keys
		i = 0
		while i < keys.length
			key = keys[i]
			label_info = @labels[key]
			draw_rect(500, label_info[:y] - 15, 250, 90, BACKGROUND_TEXT, ZOrder::BACKGROUND)
			@track_header.draw_text(label_info[:label], label_info[:x], label_info[:y], ZOrder::TOP, 1.0, 1.0, TOP_COLOR)
			i += 1
		end
	end

def draw_year_labels
    keys = @year_labels.keys
    i = 0
    while i < keys.length
      key = keys[i]
      label_info = @year_labels[key]
			draw_rect(400, label_info[:y] - 15, 450, 90, BACKGROUND_TEXT, ZOrder::BACKGROUND)
      @track_header.draw_text(label_info[:label], label_info[:x], label_info[:y], ZOrder::TOP, 1.0, 1.0, TOP_COLOR)
      i += 1
    end
end

def draw_genre_labels
    keys = @genre_labels.keys
    i = 0
    while i < keys.length
      key = keys[i]
      label_info = @genre_labels[key]
			draw_rect(500, label_info[:y] - 15, 250, 90, BACKGROUND_TEXT, ZOrder::BACKGROUND)
      @track_header.draw_text(label_info[:label], label_info[:x], label_info[:y], ZOrder::TOP, 1.0, 1.0, TOP_COLOR)
      i += 1
    end
end

def draw_albums
  y_offset = 15
  x_offset = 350
  i = 0
  while i < @albums.length
    album = @albums[i]
    draw_rect(x_offset, y_offset, 600, 200, ALBUMS_COLOR, ZOrder::BACKGROUND)
    album.artwork.dim = Dimension.new(x_offset, y_offset, x_offset + (album.artwork.bmp.width * RATIO), y_offset + (album.artwork.bmp.height * RATIO))
    album.artwork.bmp.draw(x_offset, y_offset, ZOrder::MIDDLE, RATIO, RATIO)
    @track_font.draw_text("Artist: #{album.artist}", x_offset + 300, y_offset+30, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
		@track_font.draw_text("Title: #{album.title}", x_offset + 300, y_offset+70, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
		@track_font.draw_text("Year: #{album.year}", x_offset + 300, y_offset+110, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
		@track_font.draw_text("Genre: #{$genre_names[album.genre]}", x_offset + 300, y_offset+150, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
    y_offset += 220
    i += 1
  end
	draw_rect(40,40 , 150, 70, BACKGROUND_TEXT, ZOrder::BACKGROUND)
  @track_header.draw_text("Back", 60, 50, ZOrder::TOP, 1.0, 1.0, TOP_COLOR)
end

def draw_sorted_albums
  y_offset = 15
  x_offset = 350
  sorted_albums = @current_state == :oldest_to_newest ? sorting_ascending(@albums) : sorting_descending(@albums)
  i = 0
  while i < sorted_albums.length
    album = sorted_albums[i]
    draw_rect(x_offset, y_offset, 600, 200, ALBUMS_COLOR, ZOrder::BACKGROUND)
    album.artwork.dim = Dimension.new(x_offset, y_offset, x_offset + (album.artwork.bmp.width * RATIO), y_offset + (album.artwork.bmp.height * RATIO))
    album.artwork.bmp.draw(x_offset, y_offset, ZOrder::MIDDLE, RATIO, RATIO)
    @track_font.draw_text("Artist: #{album.artist}", x_offset + 300, y_offset + 30, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
    @track_font.draw_text("Title: #{album.title}", x_offset + 300, y_offset + 70, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
    @track_font.draw_text("Year: #{album.year}", x_offset + 300, y_offset + 110, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
    @track_font.draw_text("Genre: #{$genre_names[album.genre]}", x_offset + 300, y_offset + 150, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
    y_offset += 220
    i += 1
  end
  draw_rect(40,40 , 150, 70, BACKGROUND_TEXT, ZOrder::BACKGROUND)
  @track_header.draw_text("Back", 60, 50, ZOrder::TOP, 1.0, 1.0, TOP_COLOR)
end

def draw_genre_albums
  y_offset = 200
  x_offset = 350
  albums_found = false
  i = 0
  while i < @albums.length
    if @albums[i].genre == @current_genre
      album = @albums[i]
      draw_rect(x_offset, y_offset, 600, 200, ALBUMS_COLOR, ZOrder::BACKGROUND)
      album.artwork.dim = Dimension.new(x_offset, y_offset, x_offset + (album.artwork.bmp.width * RATIO), y_offset + (album.artwork.bmp.height * RATIO))
      album.artwork.bmp.draw(x_offset, y_offset, ZOrder::MIDDLE, RATIO, RATIO)
      @track_font.draw_text("Artist: #{album.artist}", x_offset + 300, y_offset + 30, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
      @track_font.draw_text("Title: #{album.title}", x_offset + 300, y_offset + 70, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
      @track_font.draw_text("Year: #{album.year}", x_offset + 300, y_offset + 110, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
      @track_font.draw_text("Genre: #{$genre_names[album.genre]}", x_offset + 300, y_offset + 150, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
      y_offset += 220
      albums_found = true
    end
    i += 1
  end
  unless albums_found
    @track_font.draw_text("No albums found in this genre", x_offset, y_offset+200, ZOrder::TOP, 2.0, 2.0, Gosu::Color::RED)
  end
  draw_rect(40,40 , 150, 70, BACKGROUND_TEXT, ZOrder::BACKGROUND)
  @track_header.draw_text("Back", 60, 50, ZOrder::TOP, 1.0, 1.0, TOP_COLOR)
end

def draw_album_tracks()
  return unless @current_album
	draw_rect(130, 150, 1050, 650, BACKGROUND_ALBUM, ZOrder::BACKGROUND)
	draw_rect(150, 170, 510, 610, BACKGROUND_ALBUMS, ZOrder::MIDDLE)
	draw_rect(680, 170, 480, 490, Gosu::Color::BLACK, ZOrder::MIDDLE)
  @current_album.artwork.bmp.draw(180, 300, ZOrder::TOP, 1.5, 1.5)
  @track_header1.draw_text("Title: #{@current_album.title}", 180, 190, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
	@track_header1.draw_text("Artist: #{@current_album.artist}", 180, 240, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
	if @current_page >=0 && @current_page <= (@current_album.tracks.length - 1) / @track_per_page
		y = 290
		for i in (3*@current_page)..(2 + (3*@current_page))
			if i < @current_album.tracks.length
							track = @current_album.tracks[i]
							track.dim = Dimension.new(750, y, 770 + 300, y + 40)
							@track_font1.draw_text(track.name, 770, y, ZOrder::MIDDLE, 1.0, 1.0, Gosu::Color::WHITE)
							y += 100
			end
		end
	end
	if @playlist_click
		draw_rect(480,820 , 350, 70, BACKGROUND_TEXT, ZOrder::BACKGROUND)
  @track_header.draw_text("Add to playlist", 500, 825, ZOrder::TOP, 1.0, 1.0, TOP_COLOR)
	end
	if @pause == false
		@bmp = Gosu::Image.new("image/pause.png")
		@bmp.draw(840, 650 , ZOrder::TOP, 0.35, 0.35)
	else
		@bmp = Gosu::Image.new("image/play.png")
		@bmp.draw(840, 650 , ZOrder::TOP, 0.35, 0.35)
	end
	@bmp = Gosu::Image.new("image/previous.png")
  @bmp.draw(740, 650 , ZOrder::TOP, 0.35, 0.35)
	@bmp = Gosu::Image.new("image/next.png")
  @bmp.draw(940, 650, ZOrder::TOP, 0.35, 0.35)
	@bmp = Gosu::Image.new("image/up.png")
  @bmp.draw(840, 130 , ZOrder::TOP, 0.35, 0.35)
	@bmp = Gosu::Image.new("image/down.png")
  @bmp.draw(840, 530, ZOrder::TOP, 0.35, 0.35)
  draw_rect(40,40 , 150, 70, BACKGROUND_TEXT, ZOrder::BACKGROUND)
  @track_header.draw_text("Back", 60, 50, ZOrder::TOP, 1.0, 1.0, TOP_COLOR)
end

def draw_playlist
  if @playlist.empty?
    @track_header.draw_text("No tracks in the playlist", 400, 400, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
  else
		draw_rect(300, 150, 650, 650, BACKGROUND_ALBUM, ZOrder::BACKGROUND)
  	draw_rect(320, 170, 610, 490, Gosu::Color::BLACK, ZOrder::MIDDLE)
	if @current_page >=0 && @current_page <= (@playlist.length - 1) / @track_per_page
		y = 290
		for i in (3*@current_page)..(2 + (3*@current_page))
			if i < @playlist.length
							track = @playlist[i]
							track.dim = Dimension.new(450, y, 470 + 300, y + 40)
							track_number = i + 1
							@track_font1.draw_text("#{track_number}. #{track.name}", 470, y, ZOrder::MIDDLE, 1.0, 1.0, Gosu::Color::WHITE)
							y += 100
			end
		end
	end
		if @pause == false
			@bmp = Gosu::Image.new("image/pause.png")
			@bmp.draw(540, 650, ZOrder::TOP, 0.35, 0.35)
		else
			@bmp = Gosu::Image.new("image/play.png")
			@bmp.draw(540, 650, ZOrder::TOP, 0.35, 0.35)
		end
		@bmp = Gosu::Image.new("image/previous.png")
		@bmp.draw(440, 650, ZOrder::TOP, 0.35, 0.35)
		@bmp = Gosu::Image.new("image/next.png")
		@bmp.draw(640, 650, ZOrder::TOP, 0.35, 0.35)
		@bmp = Gosu::Image.new("image/left.png")
		@bmp.draw(265, 330, ZOrder::TOP, 0.35, 0.35)
		@bmp = Gosu::Image.new("image/right.png")
		@bmp.draw(810, 330, ZOrder::TOP, 0.35, 0.35)
  end
	draw_rect(40, 40, 150, 70, BACKGROUND_TEXT, ZOrder::BACKGROUND)
	@track_header.draw_text("Back", 60, 50, ZOrder::TOP, 1.0, 1.0, TOP_COLOR)
end



def draw_track_playing(album)
	@track_font1.draw("Track playing: " + album.tracks[@track_playing].name,450, 60, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
end

def draw_trackplaylist_playing(album)
	@track_font1.draw("Track playing: " + album[@track_playing].name,450, 60, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
end

def draw_track_image_playing
  track = @current_album.tracks[@track_playing]
  if @track_playing / @track_per_page == @current_page
    @bmp = Gosu::Image.new("image/music.png")
    @bmp.draw(track.dim.leftX - 100, track.dim.topY - 50, ZOrder::TOP, 0.3, 0.3)
  end
end

def draw_volume
  draw_rect(40, 260, 50, 450, Gosu::Color::WHITE, ZOrder::BACKGROUND)
  volume_height = @volume * 440
  draw_rect(45, 705 - volume_height, 40, volume_height, Gosu::Color.rgb(255, 100, 100), ZOrder::TOP)
  if @volume >= 0.75
    @bmp = Gosu::Image.new("image/threevolume.png")
    @bmp.draw(0, 700, ZOrder::TOP, 0.25, 0.25)
  elsif @volume >= 0.5
    @bmp = Gosu::Image.new("image/twovolume.png")
    @bmp.draw(0, 700, ZOrder::TOP, 0.25, 0.25)
  elsif @volume >= 0.25 || @volume > 0
    @bmp = Gosu::Image.new("image/onevolume.png")
    @bmp.draw(0, 700, ZOrder::TOP, 0.25, 0.25)
  else
    @bmp = Gosu::Image.new("image/novolume.png")
    @bmp.draw(0, 700, ZOrder::TOP, 0.25, 0.25)
  end
  @track_font1.draw("#{(@volume * 100).to_i}", 38, 200, ZOrder::MIDDLE, 1.0, 1.0, Gosu::Color::BLACK)
end


def draw
	draw_background
	draw_mouse

	if @current_state == :main
		draw_main_labels
	end

	if @current_state == :year
		draw_year_labels
	end

	if @current_state == :genre
		draw_genre_labels
	end

	if @current_state == :all_albums
		draw_albums
	end

	if @current_state == :oldest_to_newest || @current_state == :newest_to_oldest
		draw_sorted_albums
	end

	if @current_state == :genre_albums
		draw_genre_albums
	end

	if @current_state == :album_tracks
		draw_album_tracks
		draw_track_playing(@current_album)
		draw_track_image_playing
		draw_volume
	end

	if @current_state == :playlist
		draw_playlist
		if !@playlist.empty? #check if the playlist array is not empty, then draw the below code
		draw_trackplaylist_playing(@playlist)
		end
	end
end

#------------------------>Mouse click area<-------------------------
	def mouse_all(mouse_x, mouse_y)
		if mouse_x.between?(500, 700) && mouse_y.between?(210, 300)
			true
		else
			false
		end
	end

	def mouse_year(mouse_x, mouse_y)
		if mouse_x.between?(500, 700) && mouse_y.between?(360, 450)
			true
		else
			false
		end
	end

	def mouse_genre(mouse_x, mouse_y)
		if mouse_x.between?(500, 700) && mouse_y.between?(510, 600)
			true
		else
			false
		end
	end

	def mouse_playlist(mouse_x, mouse_y)
		if mouse_x.between?(500, 700) && mouse_y.between?(660, 750)
			true
		else
			false
		end
	end

	def mouse_old(mouse_x, mouse_y)
		if mouse_x.between?(400, 850) && mouse_y.between?(250, 340)
			true
		else
			false
		end
	end

	def mouse_new(mouse_x, mouse_y)
		if mouse_x.between?(400, 850) && mouse_y.between?(400, 490)
			true
		else
			false
		end
	end

	def mouse_yearback(mouse_x, mouse_y)
		if mouse_x.between?(400, 850) && mouse_y.between?(550, 640)
			true
		else
			false
		end
	end

	def mouse_pop(mouse_x, mouse_y)
		if mouse_x.between?(500, 700) && mouse_y.between?(100, 190)
			true
		else
			false
		end
	end

	def mouse_classic(mouse_x, mouse_y)
		if mouse_x.between?(500, 700) && mouse_y.between?(250, 340)
			true
		else
			false
		end
	end

	def mouse_jazz(mouse_x, mouse_y)
		if mouse_x.between?(500, 700) && mouse_y.between?(400, 490)
			true
		else
			false
		end
	end

	def mouse_rock(mouse_x, mouse_y)
		if mouse_x.between?(500, 700) && mouse_y.between?(550, 640)
			true
		else
			false
		end
	end

	def mouse_genreback(mouse_x, mouse_y)
		if mouse_x.between?(500, 700) && mouse_y.between?(700, 790)
			true
		else
			false
		end
	end

	def mouse_back(mouse_x, mouse_y)
		if mouse_x.between?(40, 190) && mouse_y.between?(40, 110)
			true
		else
			false
		end
	end

	def mouse_dim(mouse_x, mouse_y, button_x, button_y, button_width, button_height)
    mouse_x >= button_x && mouse_x <= button_x + button_width && mouse_y >= button_y && mouse_y <= button_y + button_height
  end

	def mouse_pause(mouse_x, mouse_y)
		if mouse_x.between?(860, 960) && mouse_y.between?(690, 790)
			true
		else
			false
		end
	end

	def mouse_playlist_pause(mouse_x, mouse_y)
		if mouse_x.between?(580, 660) && mouse_y.between?(690, 790)
			true
		else
			false
		end
	end

	def mouse_up(mouse_x, mouse_y)
		if mouse_x.between?(880, 960) && mouse_y.between?(180, 240)
			true
		else
			false
		end
	end

	def mouse_down(mouse_x, mouse_y)
		if mouse_x.between?(880, 960) && mouse_y.between?(580, 630)
			true
		else
			false
		end
	end

	def mouse_playlist_up(mouse_x, mouse_y)
		if mouse_x.between?(315, 385) && mouse_y.between?(380, 450)
			true
		else
			false
		end
	end

	def mouse_playlist_down(mouse_x, mouse_y)
		if mouse_x.between?(860, 930) && mouse_y.between?(375, 455)
			true
		else
			false
		end
	end

	def mouse_left(mouse_x, mouse_y)
		if mouse_x.between?(780, 860) && mouse_y.between?(690, 770)
			true
		else
			false
		end
	end

	def mouse_right(mouse_x, mouse_y)
		if mouse_x.between?(980, 1060) && mouse_y.between?(690, 770)
			true
		else
			false
		end
	end

	def mouse_playlist_left(mouse_x, mouse_y)
		if mouse_x.between?(480, 560) && mouse_y.between?(690, 770)
			true
		else
			false
		end
	end

	def mouse_playlist_right(mouse_x, mouse_y)
		if mouse_x.between?(680, 760) && mouse_y.between?(690, 770)
			true
		else
			false
		end
	end

	def mouse_playlist_click(mouse_x, mouse_y)
		if mouse_x.between?(470, 830) && mouse_y.between?(820, 890)
			true
		else
			false
		end
	end

	def mouse_volume(mouse_x, mouse_y)
		if mouse_x.between?(30, 90) && mouse_y.between?(250, 720)
			 return true
		end
		return false
	end

#-------------------------->Button_down function<---------------------
def button_down(id)
  case @current_state
  when :main
    main_click(id)
  when :year
    year_click(id)
  when :genre
    genre_click(id)
  when :all_albums
    album_click(id)
    album_back_click(id)
  when :oldest_to_newest, :newest_to_oldest
    sorted_album_click(id)
    album_back_click(id)
  when :genre_albums
    genre_album_click(id)
    album_back_click(id)
  when :album_tracks
    track_click(id)
		track_right_click(id)
    album_back_click(id)
		pause_click(id)
		page_click(id)
		left_click(id)
		right_click(id)
		volume_click(id)
	when :playlist
		track_playlist_click(id)
    album_back_click(id)
		playlist_pause_click(id)
		playlist_page_click(id)
		playlist_left_click(id)
		playlist_right_click(id)
		album_back_click(id)
	end
end

	def needs_cursor?; true; end
#------------------->Procedures click functions<----------------------
def main_click(id)
if id == Gosu::MsLeft
	if mouse_all(mouse_x, mouse_y)
		@current_state = :all_albums
	elsif mouse_year(mouse_x, mouse_y)
		@current_state = :year
	elsif mouse_genre(mouse_x, mouse_y)
		@current_state = :genre
	elsif mouse_playlist(mouse_x, mouse_y)
		@current_state = :playlist
		if @playlist.any? #check if the playlist not empty
			album = nil
			i = 0
			while i < @albums.length
				alb = @albums[i]
				if alb.tracks.include?(@playlist[0]) #check if it contains the track in the playlist
					album = alb
					break
				end
				i += 1
			end
			@current_album = album if album #set the current album if found
			@track_playing = 0 #reset to first track when exist
			playTrack(@playlist[0].location)
		end
	end
end
end

def year_click(id)
	if id == Gosu::MsLeft
		if mouse_old(mouse_x, mouse_y)
			@current_state = :oldest_to_newest
		elsif mouse_new(mouse_x, mouse_y)
			@current_state = :newest_to_oldest
		elsif mouse_yearback(mouse_x, mouse_y)
			@current_state = :main
		end
	end
end

def genre_click(id)
	if id == Gosu::MsLeft
		if mouse_pop(mouse_x, mouse_y)
			@current_genre = Genre::POP
			@current_state = :genre_albums
		elsif mouse_classic(mouse_x, mouse_y)
			@current_genre = Genre::CLASSIC
			@current_state = :genre_albums
		elsif mouse_jazz(mouse_x, mouse_y)
			@current_genre = Genre::JAZZ
			@current_state = :genre_albums
		elsif mouse_rock(mouse_x, mouse_y)
			@current_genre = Genre::ROCK
			@current_state = :genre_albums
		elsif mouse_genreback(mouse_x, mouse_y)
			@current_state = :main
		end
	end
end

def album_back_click(id)
	if id == Gosu::MsLeft
		if mouse_back(mouse_x, mouse_y)
			@current_state = :main if @current_state == :all_albums
			@current_state = :year if @current_state == :oldest_to_newest || @current_state == :newest_to_oldest
			@current_state = :genre if @current_state == :genre_albums
			@current_state = :main if @current_state == :playlist
      @current_state = :all_albums if @current_state == :album_tracks
			@song.pause if @song && @song.playing? #song will pause if click on back button
			@current_page = 0 #reset the tracklist page
		end
	end
end

	def back_click(id)
		if id == Gosu::MsLeft
			if mouse_back
				case @current_state
				when :year
					@current_state = :main
				when :genre_albums
					@current_state = :genre
				when :all_albums
					@current_state = :main
				when :oldest_to_newest, :newest_to_oldest
					@current_state = :year
				end
			end
		end
	end

  def album_click(id)
		return unless id == Gosu::MsLeft
		i = 0
		while i < @albums.length
			album = @albums[i]
			if mouse_dim(mouse_x, mouse_y, album.artwork.dim.leftX, album.artwork.dim.topY, album.artwork.dim.rightX - album.artwork.dim.leftX, album.artwork.dim.bottomY - album.artwork.dim.topY)
				@current_album = album
				@current_state = :album_tracks
				@pause = false
				@track_playing = 0 #song will play again if click the back button
				playTrack(@current_album.tracks[0].location)
				break
			end
			i += 1
		end
	end

  def sorted_album_click(id)
		return unless id == Gosu::MsLeft
	#array is created based on the current state, either sorting ascending or descending.
		sorted_albums = @current_state == :oldest_to_newest ? sorting_ascending(@albums) : sorting_descending(@albums)
		i = 0
		while i < sorted_albums.length
			album = sorted_albums[i]
			if mouse_dim(mouse_x, mouse_y, album.artwork.dim.leftX, album.artwork.dim.topY, album.artwork.dim.rightX - album.artwork.dim.leftX, album.artwork.dim.bottomY - album.artwork.dim.topY)
				@current_album = album
				@current_state = :album_tracks
				@pause = false
				@track_playing = 0 #song will play again if click the back button
				playTrack(@current_album.tracks[0].location)
				break
			end
			i += 1
		end
	end


  def genre_album_click(id)
		return unless id == Gosu::MsLeft
		i = 0
		while i < @albums.length
			album = @albums[i]
			if album.genre == @current_genre
				if mouse_dim(mouse_x, mouse_y, album.artwork.dim.leftX, album.artwork.dim.topY, album.artwork.dim.rightX - album.artwork.dim.leftX, album.artwork.dim.bottomY - album.artwork.dim.topY)
					@current_album = album
					@current_state = :album_tracks
					@pause = false
					@track_playing = 0 #song will play again if click the back button
					playTrack(@current_album.tracks[0].location)
					break
				end
			end
			i += 1
		end
	end

	def track_click(id)
		return unless id == Gosu::MsLeft
		if @playlist_click && mouse_dim(mouse_x, mouse_y, 480, 820, 350, 70)
			if @selected_track && !@playlist.include?(@selected_track) #if selected track exists and isn't already in the playlist
				@playlist << @selected_track #add to playlist
			end
			@playlist_click = false
			@selected_track = nil
			return
		end

		if @current_page >= 0 && @current_page <= (@current_album.tracks.length - 1) / @track_per_page
			track_start = @track_per_page * @current_page
			track_end = [@current_album.tracks.length - 1, track_start + 2].min
			i = track_start
			while i <= track_end
				track = @current_album.tracks[i]
				if track && mouse_dim(mouse_x, mouse_y, track.dim.leftX, track.dim.topY, track.dim.rightX - track.dim.leftX, track.dim.bottomY - track.dim.topY)
					@pause = false
					@track_playing = i
					playTrack(track.location)
				end
				i += 1
			end
		end
	end

def track_playlist_click(id)
  return unless id == Gosu::MsLeft
  if @current_page >= 0 && @current_page <= (@playlist.length - 1) / @track_per_page
    track_start = @track_per_page * @current_page
    track_end = [@playlist.length - 1, track_start + 2].min
		i = track_start
    while i <= track_end
      track = @playlist[i]
      if track && mouse_dim(mouse_x, mouse_y, track.dim.leftX, track.dim.topY, track.dim.rightX - track.dim.leftX, track.dim.bottomY - track.dim.topY)
        @pause = false
        @track_playing = i
        playTrack(track.location)
			end
			i += 1
    end
  end
end

def track_right_click(id)
  return unless id == Gosu::MsRight
  if @current_page >= 0 && @current_page <= (@current_album.tracks.length - 1) / @track_per_page #check if the page in the valid range (first page to last page)
    track_start = @track_per_page * @current_page
    track_end = [@current_album.tracks.length - 1, track_start + 2].min # (track_start +2) make sure that the last page displays at least one track if there are any left
    i = track_start
    while i <= track_end
      track = @current_album.tracks[i]
      if track && mouse_dim(mouse_x, mouse_y, track.dim.leftX, track.dim.topY, track.dim.rightX - track.dim.leftX, track.dim.bottomY - track.dim.topY)
        @selected_track = track #the clicked track is assigned to @selected_track
        @playlist_click = true
        return
      end
      i += 1
    end
  end
end


	def pause_click(id)
		if id == Gosu::MsLeft
			if @pause == false
				if mouse_pause(mouse_x, mouse_y)
						@pause = true
						@song.pause
				end
			else
					if mouse_pause(mouse_x, mouse_y)
							@song.play
							@pause = false
					end
			end
		end
	end

	def playlist_pause_click(id)
		if id == Gosu::MsLeft
			if @pause == false #song not pause
				if mouse_playlist_pause(mouse_x, mouse_y)
						@pause = true #swiggle the playback to pause image
						@song.pause #song pause
				end
			else
					if mouse_playlist_pause(mouse_x, mouse_y)
							@song.play #song play
							@pause = false #swiggle the playback to play image
					end
			end
		end
	end

	def page_click(id)
		if id == Gosu::MsLeft
			if mouse_up(mouse_x, mouse_y)
				if @current_page > 0 #can go back to previous page if not the first page
					@current_page -= 1
				else
					@current_page = (@current_album.tracks.length - 1) / @track_per_page #otherwise go to last page
				end
			end

			if mouse_down(mouse_x, mouse_y)
				if @current_page < (@current_album.tracks.length - 1) / @track_per_page #can move to next page if not the last page
					@current_page += 1
				else
					@current_page = 0 #otherwise go to first page
				end
			end
		end
	end

		def playlist_page_click(id)
			if id == Gosu::MsLeft
				if mouse_playlist_up(mouse_x, mouse_y)
					if @current_page > 0 #can go back to previous page if not the first page
						@current_page -= 1
					else
						@current_page = (@playlist.length - 1) / @track_per_page #otherwise go to last page
					end
				end

				if mouse_playlist_down(mouse_x, mouse_y)
					if @current_page < (@playlist.length - 1) / @track_per_page #can move to next page if not the last page
						@current_page += 1
					else
						@current_page = 0 #otherwise go to first page
					end
				end
			end
		end

		def left_click(id)
			if id == Gosu::MsLeft
				if mouse_left(mouse_x, mouse_y)
					@pause = false
					if @track_playing > 0 #make sure it can move to previous song if it's not the first song
						@track_playing -= 1
					else
						@track_playing = @current_album.tracks.length - 1 #otherwise go to last song if it's first song
					end
					@current_page = @track_playing / @track_per_page
					track_location = @current_album.tracks[@track_playing].location
					playTrack(track_location)
				end
			end
		end

		def right_click(id)
			if id == Gosu::MsLeft
				if mouse_right(mouse_x, mouse_y)
					@pause = false
					if @track_playing < @current_album.tracks.length - 1 #make sure it can move to next song
						@track_playing += 1
					else
						@track_playing = 0 #otherwise it's the last song, so go back to first song
					end
					@current_page = @track_playing / @track_per_page
					track_location = @current_album.tracks[@track_playing].location
					playTrack(track_location)
				end
			end
		end

		def playlist_left_click(id)
			if id == Gosu::MsLeft
				if mouse_playlist_left(mouse_x, mouse_y)
					@pause = false
					if @track_playing > 0 #make sure it can move to previous song if it's not the first song
						@track_playing -= 1
					else
						@track_playing = @playlist.length - 1 #otherwise go to last song if it's first song
					end
					@current_page = @track_playing / @track_per_page
					track_location = @playlist[@track_playing].location
					playTrack(track_location)
				end
			end
		end

		def playlist_right_click(id)
			if id == Gosu::MsLeft
				if mouse_playlist_right(mouse_x, mouse_y)
					@pause = false #song not pause
					if @track_playing < @playlist.length - 1 #make sure it can move to next song
						@track_playing += 1
					else
						@track_playing = 0 #otherwise it's the last song, so go back to first song
					end
					@current_page = @track_playing / @track_per_page
					track_location = @playlist[@track_playing].location
					playTrack(track_location)
				end
			end
		end

		def volume_click(id)
			if id == Gosu::MsLeft
				if mouse_volume(mouse_x, mouse_y)
					volume_level = 1 - (mouse_y - 260) / 450
					# make sure volume level stays within the valid range of 0 to 1
					@volume = [[volume_level, 0].max, 1].min
					@song.volume = @volume
					@change_volume = true
				end
			end
		end
	end

MusicPlayerMain.new.show if __FILE__ == $0
