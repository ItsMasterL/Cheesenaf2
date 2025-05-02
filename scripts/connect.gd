extends Node

var process = "bbgsim"
var game_open = false
var run_thread = true
var thread: Thread

func _ready():
	thread = Thread.new()
	thread.start(_passive_game_check)

func _check_for_process():
	if OS.get_name() == "Windows":
		var output = []
		#Runs powershell
		OS.execute('powershell.exe', ['/C', "get-process %s" % [process]], output)
		var last_check = game_open
		game_open = output.size() > 0 && output[0].contains("Cannot find") == false
		return game_open

func _passive_game_check():
	while run_thread:
		_check_for_process()

func _exit_tree() -> void:
	run_thread = false
	thread.wait_to_finish()

func _connect_games():
	if game_open:
		var output = []
		#Runs powershell
		OS.execute('powershell.exe', ['/C', "get-process %s | Select-Object -ExpandProperty Path" % [process]], output)
		var string = output[0] as String
		var i = string.length() - 1
		while (string[i] != '/') && (string[i] != '\\'):
			string = string.left(string.length() - 1)
			i -= 1
		print(string)
		Globals.cheesenaf1_path = string
		$"../"._change_menu("code")
	else:
		$"../ErrorSound".play()
