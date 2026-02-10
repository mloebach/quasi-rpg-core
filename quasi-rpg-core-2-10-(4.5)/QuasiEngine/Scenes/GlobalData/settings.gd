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

var default_values := {
	"current_window_size_index" : 2,
	"current_window_mode_index" : 0,
	"current_resizable_window_toggle" : 0,
	"main_volume" : 50.0,
	"bgm_volume" : 50.0,
	"sfx_volume" : 50.0,
	"voice_volume" : 50.0,
	"tts_toggle" : false,
	"current_tts_voice" : 0,
	"last_opened_tab" : ""
}

var tts_voices

var settings_options : SettingOptions = SettingOptions.new()

var last_opened_tab : String = ""

#var current_window_size_index : int
#var current_window_mode_index : int
#var current_resizable_window_toggle : int #0 = false, 1=true
#
##audio
#var main_volume := 50.0
#var bgm_volume := 50.0
#var sfx_volume := 50.0
#var voice_volume := 50.0
#
#var tts_toggle := false
#var tts_voices
#var current_tts_voice : int = 0



func _ready() -> void:
	_load_values()
	_initial_screen_graphics()

func _load_values():
	print("loading setting values")
	if not FileAccess.file_exists(GlobalData.settings_path):
		return
	var global_save = FileAccess.open(GlobalData.settings_path, FileAccess.READ)
	#global_save.get_line() #skip first line
	var settings_json = global_save.get_line()
	var json = JSON.new()
	var parse_result = json.parse(settings_json)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", settings_json, " at line ", json.get_error_line())
		return
	var node_data = json.data
	for i in node_data.keys():
		settings_options[i] = node_data[i]

func _initial_screen_graphics():
	update_window_size(settings_options.current_window_size_index)
	window_mode_select(settings_options.current_window_mode_index)	
	resize_toggle(settings_options.current_resizable_window_toggle)



#func save():
	#var save_dict = {
		#"current_window_size_index": current_window_size_index,
		#"current_window_mode_index": current_window_mode_index,
		#"current_resizable_window_toggle" : current_resizable_window_toggle,
		#
		#"main_volume": main_volume,
		#"bgm_volume": bgm_volume,
		#"sfx_volume": sfx_volume,
		#"voice_volume": voice_volume,
		#
		#"tts_toggle" : tts_toggle,
		#"current_tts_voice": current_tts_voice
	#}
	#return save_dict
#
#func save_game():
	#var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	#var json_string = JSON.stringify(save())
	#save_file.store_line(json_string)
	
func set_values_to_default():
	for item in default_values:
		settings_options[item] = default_values[item]
	
#func load_game():
	#if not FileAccess.file_exists("user://savegame.save"):
		#return #Error, we don't have save file
	#
	##load file line by line and process dictionary
	#var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	#
	#while save_file.get_position() < save_file.get_length():
		#var json_string = save_file.get_line()
		#var json = JSON.new()
		#
		#var parse_result = json.parse(json_string)
		#if not parse_result == OK:
			#print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			#continue
			#
		## Get the data from the JSON object.
		#var node_data = json.data
#
		## Now we set the remaining variables.
		#for i in node_data.keys():
			#settings_options[i] = node_data[i]
			
		
func get_current_tts_voice():
	return settings_options.current_tts_voice
	
func save_settings():
	var settings_data = FileAccess.open(GlobalData.settings_path, FileAccess.WRITE)
	settings_data.store_line(
		JSON.stringify(Util.to_json(settings_options.to_dict()).data)
	)
	settings_data.close()

func resize_toggle(index: int):
	settings_options.current_resizable_window_toggle = index
	match index:
		0: 
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)
		1:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, false)
	save_settings()

func window_mode_select(index: int) -> void:
	#windowed = 0, fullscreen = 1, borderless = 2
	Settings.settings_options.current_window_mode_index = index
	match index:
		0:
			#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			#_update_window_size(GlobalData.current_window_size_index)
			_set_windowed_mode()
		1:
			_set_fullscreen_mode()
		2:
			_set_borderless_fullscreen_mode()
		_:
			push_error("Window mode not found!")
	Settings.save_settings()

func _set_windowed_mode():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	update_window_size(settings_options.current_window_size_index)

func _set_fullscreen_mode():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _set_borderless_fullscreen_mode():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

func update_window_size(index: int):
	#GlobalData.current_window_size_index = index
	Settings.settings_options.current_window_size_index = index
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		get_viewport().size = _resolution_string_to_vector(display_resolutions[index])
	Settings.save_settings()


func _resolution_string_to_vector(res : String) -> Vector2:
	
	var split_string = res.split("x", false, 1)
	var dimensions := Vector2(
		int(split_string[0].strip_edges()), int(split_string[1].strip_edges())
	)
	
	return dimensions



#default values
class SettingOptions:
	var current_window_size_index : int
	var current_window_mode_index : int
	var current_resizable_window_toggle : int #0 = false, 1=true

	#audio
	var main_volume : float
	var bgm_volume : float
	var sfx_volume : float
	var voice_volume : float

	var tts_toggle : bool
	var current_tts_voice : int
	
	var last_opened_tab : String
	
	#func _init(default_res: int):
		#current_window_mode_index = default_res
	
	func to_dict():
		var dict = {
			"current_window_size_index" : current_window_size_index,
			"current_window_mode_index" : current_window_mode_index,
			"current_resizable_window_toggle" : current_resizable_window_toggle,
			"main_volume" : main_volume,
			"bgm_volume" : bgm_volume,
			"sfx_volume" : sfx_volume,
			"voice_volume" : voice_volume,
			"tts_toggle" : tts_toggle,
			"current_tts_voice" : current_tts_voice,
			"last_opened_tab" : last_opened_tab
		}
		return dict
