extends Node2D

@onready var audio_player := $"../../MediaPlayer"
@onready var video_player := $Home/VideoStreamPlayer
@onready var progress_bar := $Home/ProgressBar
@onready var current_position := $Home/CurrentPosition
@onready var length := $Home/Length
@onready var root = $"../.."


# Called when the node enters the scene tree for the first time.
func _ready():
	root.media_player_is_open = true
	$Home/Volume.value = root.volume
	if root.is_media_playing:
		if root.is_video:
			progress_bar.value = video_player.stream_position
			current_position.text = "%02d:%02d:%02d" % [floor(video_player.stream_position / 60 / 60), fmod(floor(video_player.stream_position / 60), 60), fmod(video_player.stream_position, 60)]
		else:
			progress_bar.value = audio_player.get_playback_position()
			current_position.text = "%02d:%02d:%02d" % [floor(audio_player.get_playback_position() / 60 / 60), fmod(floor(audio_player.get_playback_position() / 60), 60), fmod(audio_player.get_playback_position(), 60)]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	root.is_media_playing = audio_player.playing or video_player.is_playing()
	if root.queued_media != "" and root.is_media_playing == false:
		if root.queued_media.ends_with(".ogv") and root.is_media_playing == false:
			root.is_video = true
			var video = VideoStreamTheora.new()
			video.file = root.queued_media
			video_player.stream = video
			video_player.play()
			#TODO: Find another way to get video file length
			progress_bar.max_value = video_player.get_stream_length()
			length.text = "%02d:%02d:%02d" % [floor(video_player.get_stream_length() / 60 / 60), fmod(floor(video_player.get_stream_length() / 60), 60), fmod(video_player.get_stream_length(), 60)]
			root.queued_media = ""
		elif root.queued_media.ends_with(".mp3") and audio_player.stream == null:
			root.is_video = false
			var file = FileAccess.open(root.queued_media, FileAccess.READ)
			var sound = AudioStreamMP3.new()
			sound.data = file.get_buffer(file.get_length())
			progress_bar.max_value = sound.get_length()
			length.text = "%02d:%02d:%02d" % [floor(sound.get_length() / 60 / 60), fmod(floor(sound.get_length() / 60), 60), fmod(sound.get_length(), 60)]
			audio_player.stream = sound
			audio_player.play()
			root.queued_media = ""
		elif root.queued_media.ends_with(".wav") and audio_player.stream == null:
			root.queued_media = ""
			return # They just play back static rn
			root.is_video = false # TODO: Unreachable code (statement after return) in function "_process()".
			var file = FileAccess.open(root.queued_media, FileAccess.READ)
			var sound = AudioStreamWAV.new()
			sound.data = file.get_buffer(file.get_length())
			progress_bar.max_value = sound.get_length()
			length.text = "%02d:%02d:%02d" % [floor(sound.get_length() / 60 / 60), fmod(floor(sound.get_length() / 60), 60), fmod(sound.get_length(), 60)]
			audio_player.stream = sound
			audio_player.play()
			root.queued_media = ""
		elif root.queued_media.ends_with(".ogg") and audio_player.stream == null:
			root.is_video = false
			var sound = AudioStreamOggVorbis.new()
			# TODO: The function "load_from_file()" is a static function but was called from an instance. Instead, it should be directly called from the type: "AudioStreamOggVorbis.load_from_file()".
			sound.load_from_file(root.queued_media)
			progress_bar.max_value = sound.get_length()
			length.text = "%02d:%02d:%02d" % [floor(sound.get_length() / 60 / 60), fmod(floor(sound.get_length() / 60), 60), fmod(sound.get_length(), 60)]
			audio_player.stream = sound
			audio_player.play()
			root.queued_media = ""
		elif audio_player.stream == null:
			print("Discarded file %s" % [root.queued_media])
			root.queued_media = ""
		
	elif root.playlist.size() > 0 and root.queued_media == "":
		root.queued_media = root.playlist[0]
		root.playlist.remove_at(0)
		#if root.is_paused == false:
		#	if root.is_video:
		#		video_player.stop()
		#		video_player.stream = null
		#	else:
		#		audio_player.stop()
		#		audio_player.stream = null
		#	progress_bar.value = 0
	
	if root.is_media_playing:
		if root.is_video:
			progress_bar.value = video_player.stream_position
			current_position.text = "%02d:%02d:%02d" % [floor(video_player.stream_position / 60 / 60), fmod(floor(video_player.stream_position / 60), 60), fmod(video_player.stream_position, 60)]
		else:
			progress_bar.value = audio_player.get_playback_position()
			current_position.text = "%02d:%02d:%02d" % [floor(audio_player.get_playback_position() / 60 / 60), fmod(floor(audio_player.get_playback_position() / 60), 60), fmod(audio_player.get_playback_position(), 60)]

func _exit_tree():
	root.media_player_is_open = false

#TODO: Restore loading .wav and .ogg (.wav played static, .ogg didn't play at all) 
func _on_dir_selected(dir: String):
	var directory = DirAccess.open(dir)
	if directory:
		directory.list_dir_begin()
		var path = directory.get_next()
		while path != "":
			if directory.current_is_dir() == false:
				if path.ends_with(".mp3") or path.ends_with(".ogv"):
					root.playlist.append(dir + "/" + path)
			path = directory.get_next()

func _on_file_selected(path: String):
	if FileAccess.file_exists(path):
		if path.ends_with(".mp3") or path.ends_with(".ogv"):
			root.playlist.append(path)

func _on_files_selected(paths: PackedStringArray):
	for path in paths:
		if FileAccess.file_exists(path):
			if path.ends_with(".mp3") or path.ends_with(".ogv"):
				root.playlist.append(path)

func _open_files():
	$Home/Media.visible = true
	
func _open_directory():
	$Home/Directory.visible = true

func _play_pause():
	if root.is_video:
		video_player.paused = !video_player.paused
		root.is_paused = video_player.paused
	else:
		audio_player.stream_paused = !audio_player.stream_paused
		root.is_paused = audio_player.stream_paused

func _skip():
	if root.is_video:
		video_player.stop()
		video_player.stream = null
	else:
		audio_player.stop()
		audio_player.stream = null
	progress_bar.value = 0

func _shuffle():
	print("Shuffled playlist")
	root.playlist.shuffle()

func _set_volume(vol: float):
	root.volume = vol
	root.audio_player.volume_db = linear_to_db(root.volume)
