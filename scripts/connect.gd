extends Node

const PROCESS = "BBGSim"
var game_open = false
var run_thread = true
var thread: Thread

func _ready():
	if Globals.cheesenaf1_code != "":
		queue_free()
	else:
		thread = Thread.new()
		thread.start(_passive_game_check)

func _check_for_process():
	var output = []
	if OS.get_name() == "Windows":
		#Runs powershell
		OS.execute('powershell.exe', ['/C', "get-process %s" % [PROCESS.to_lower()]], output)
		game_open = output.size() > 0 and output[0].contains("Cannot find") == false
		return game_open
	if OS.get_name() == "Linux":
		#Runs in console
		OS.execute('pgrep', ['BBGSim'], output)
		game_open = output.size() > 0 and output[0] != ""
		return game_open

func _passive_game_check():
	while run_thread:
		_check_for_process()

func _exit_tree() -> void:
	run_thread = false
	if Globals.cheesenaf1_code == "":
		thread.wait_to_finish()

func _connect_games():
	if game_open:
		var output = []
		var string = ""
		if OS.get_name() == "Windows":
			#Runs powershell
			OS.execute('powershell.exe', ['/C', "get-process %s | Select-Object -ExpandProperty Path" % [PROCESS.to_lower()]], output)
			string = output[0].strip_edges() as String
			Globals.cheesenaf1_app = string
		if OS.get_name() == "Linux":
			var output2 = []
			#Runs in console
			OS.execute('pgrep', [PROCESS], output)
			OS.execute('readlink', ["/proc/%s/exe" % [output[0]]], output2)
			string = output2[0]
		var i = string.length() - 1
		while (string[i] != '/') and (string[i] != '\\'):
			string = string.left(string.length() - 1)
			i -= 1
		if OS.is_debug_build():
			print(string)
		Globals.cheesenaf1_path = string
		$"../"._change_menu("code")
	else:
		$"../ErrorSound".play()
