extends Node
class_name SettingValues

#display options
@export var display_resolutions : Array[String] = [
	"3840 x 2160",
	"2560 x 1440",
	"1920 x 1080",
	"1680 x 1050",
	"1600 x 900",
	"1440 x 900",
	"1366 x 768",
	"1280 x 960",
	"1280 x 720",
	"1024 x 768"
	
]

var current_window_size_index : int
var current_window_mode_index : int
var current_resizable_window_toggle : int #0 = false, 1=true

#audio
var main_volume := 50.0
var bgm_volume := 50.0
var sfx_volume := 50.0
var voice_volume := 50.0

var tts_toggle := false
var tts_voices
var current_tts_voice : int = 0


func _ready() -> void:
	pass

func save():
	var save_dict = {
		"current_window_size_index": current_window_size_index,
		"current_window_mode_index": current_window_mode_index,
		"current_resizable_window_toggle" : current_resizable_window_toggle,
		
		"main_volume": main_volume,
		"bgm_volume": bgm_volume,
		"sfx_volume": sfx_volume,
		"voice_volume": voice_volume,
		
		"tts_toggle" : tts_toggle,
		"current_tts_voice": current_tts_voice
	}
	return save_dict

func save_game():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var json_string = JSON.stringify(save())
	save_file.store_line(json_string)
	
	
func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return #Error, we don't have save file
	
	#load file line by line and process dictionary
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
			
		# Get the data from the JSON object.
		var node_data = json.data

		# Now we set the remaining variables.
		for i in node_data.keys():
			self.set(i, node_data[i])
			
		
func get_current_tts_voice():
	return current_tts_voice
