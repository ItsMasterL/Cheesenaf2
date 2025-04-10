extends Node2D


var playlist: Array[String]
var queued_media: String = ""
var is_media_playing = false
var is_video = false

@onready var audioplayer := $Home/AudioStreamPlayer
@onready var videoplayer := $Home/VideoStreamPlayer
@onready var progressbar := $Home/ProgressBar
@onready var current_position := $Home/CurrentPosition
@onready var length := $Home/Length


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	is_media_playing = audioplayer.playing || videoplayer.is_playing()
	if queued_media != "" && is_media_playing == false:
		if queued_media.ends_with(".ogv") && is_media_playing == false:
			is_video = true
			var video = VideoStreamTheora.new()
			video.file = queued_media
			videoplayer.stream = video
			videoplayer.play()
			#TODO: Find another way to get video file length
			progressbar.max_value = videoplayer.get_stream_length()
			length.text = "%02d:%02d:%02d" % [floor(videoplayer.get_stream_length() / 60 / 60), fmod(floor(videoplayer.get_stream_length() / 60), 60), fmod(videoplayer.get_stream_length(), 60)]
			queued_media = ""
		elif queued_media.ends_with(".mp3") && audioplayer.stream == null:
			is_video = false
			var file = FileAccess.open(queued_media, FileAccess.READ)
			var sound = AudioStreamMP3.new()
			sound.data = file.get_buffer(file.get_length())
			progressbar.max_value = sound.get_length()
			length.text = "%02d:%02d:%02d" % [floor(sound.get_length() / 60 / 60), fmod(floor(sound.get_length() / 60), 60), fmod(sound.get_length(), 60)]
			audioplayer.stream = sound
			audioplayer.play()
			queued_media = ""
		elif queued_media.ends_with(".wav") && audioplayer.stream == null:
			queued_media = ""
			return # They just play back static rn
			is_video = false # TODO: Unreachable code (statement after return) in function "_process()".
			var file = FileAccess.open(queued_media, FileAccess.READ)
			var sound = AudioStreamWAV.new()
			sound.data = file.get_buffer(file.get_length())
			progressbar.max_value = sound.get_length()
			length.text = "%02d:%02d:%02d" % [floor(sound.get_length() / 60 / 60), fmod(floor(sound.get_length() / 60), 60), fmod(sound.get_length(), 60)]
			audioplayer.stream = sound
			audioplayer.play()
			queued_media = ""
		elif queued_media.ends_with(".ogg") && audioplayer.stream == null:
			is_video = false
			var sound = AudioStreamOggVorbis.new()
			# TODO: The function "load_from_file()" is a static function but was called from an instance. Instead, it should be directly called from the type: "AudioStreamOggVorbis.load_from_file()".
			sound.load_from_file(queued_media)
			progressbar.max_value = sound.get_length()
			length.text = "%02d:%02d:%02d" % [floor(sound.get_length() / 60 / 60), fmod(floor(sound.get_length() / 60), 60), fmod(sound.get_length(), 60)]
			audioplayer.stream = sound
			audioplayer.play()
			queued_media = ""
		
	elif playlist.size() > 0 && queued_media == "":
		queued_media = playlist[0]
		playlist.remove_at(0)
	
	if is_media_playing:
		if is_video:
			progressbar.value = videoplayer.stream_position
			current_position.text = "%02d:%02d:%02d" % [floor(videoplayer.stream_position / 60 / 60), fmod(floor(videoplayer.stream_position / 60), 60), fmod(videoplayer.stream_position, 60)]
		else:
			progressbar.value = audioplayer.get_playback_position()
			current_position.text = "%02d:%02d:%02d" % [floor(audioplayer.get_playback_position() / 60 / 60), fmod(floor(audioplayer.get_playback_position() / 60), 60), fmod(audioplayer.get_playback_position(), 60)]

#TODO: Restore loading .wav and .ogg (.wav played static, .ogg didn't play at all) 
func _on_dir_selected(dir: String):
	var directory = DirAccess.open(dir)
	if directory:
		directory.list_dir_begin()
		var path = directory.get_next()
		while path != "":
			if directory.current_is_dir() == false:
				if path.ends_with(".mp3") || path.ends_with(".ogv"):
					playlist.append(dir + "/" + path)
			path = directory.get_next()

func _on_file_selected(path: String):
	if FileAccess.file_exists(path):
		if path.ends_with(".mp3") || path.ends_with(".ogv"):
			playlist.append(path)

func _on_files_selected(paths: PackedStringArray):
	for path in paths:
		if FileAccess.file_exists(path):
			if path.ends_with(".mp3") || path.ends_with(".ogv"):
				playlist.append(path)

func _open_files():
	$Home/Media.visible = true
	
func _open_directory():
	$Home/Directory.visible = true

func _play_pause():
	if is_video:
		videoplayer.paused = !videoplayer.paused
	else:
		audioplayer.stream_paused = !audioplayer.stream_paused

func _skip():
	if is_video:
		videoplayer.stop()
		videoplayer.stream = null
	else:
		audioplayer.stop()
		audioplayer.stream = null
	progressbar.value = 0

func _shuffle():
	playlist.shuffle()
