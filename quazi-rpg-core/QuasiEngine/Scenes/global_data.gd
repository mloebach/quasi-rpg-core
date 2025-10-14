#data that persists between scenes

extends Node
class_name Global_Data


#we're putting the story trees here so we don't need to do it over and over

#var global_save : GlobalSave = preload("res://QuasiEngine/Scenes/_Debug/Test_saves/test_global_fresh.tres")
const game_name : String = "Zenith Project"
const main_folder : String = "user://"+game_name+"/"
const global_save_path : String = "user://"+game_name+"/global_save.json"
const settings_path : String = "user://"+game_name+"/settings.json"

var global_save : GlobalSave = GlobalSave.new()
#Only one active player save at a time
var player_save: PlayerSave = PlayerSave.new()
var game_db: VN_Database = preload("res://Game Files/Zenith Day August 23/Database/z_game_database.tres")
var current_scene_status = SceneTypes.out_of_game
enum SceneTypes {
	in_game,
	out_of_game
}

var script_data_loaded : bool = false
var opening_script : String
var starting_location: String = "The Spring"
var starting_quest: String = "Prelude"
var script_trees : Dictionary [String, SceneTranspiler.StoryTree] = {
	
}
var current_script: String = ""
var current_label: String = ""
var subscript_stack: Array[StoryPlayer.ScenarioLine]

var auto_printer_on := false
var auto_timer := 0.0
var auto_timer_wait := 1.5
var printer_paused := false



#add variable restriction that makes it so certain variables are locked
#and cannot be edited by @set
var ingame_variables := {
	
}

var characters : Dictionary[String, Char_Resource] ={
	
}

var printers := {
	
}

#var current_printer: String = "null"
var custom_global_data_type = Zenith_Global_Data
var custom_global_data

var custom_command_type = ZenithCustomCommands
var custom_command_functions


func _ready() -> void:
	_load_global_data()
	_load_printers()
	_load_characters()
	_set_tts_voices()
	custom_command_functions = custom_command_type.new()
	custom_global_data = custom_global_data_type.new()
	opening_script = game_db.initial_script
	#tts_speak("welcome to the fuckhouse, bitch!")
	

func get_current_player_save() -> PlayerSave:
#func get_current_player_save() -> String:
	#pla
	var player_save = PlayerSave.new()
	var json = FileAccess.open(global_save.get_current_save(), FileAccess.READ)
	return player_save.load_save(json)
	
func _load_global_data() -> void:
	print("loading global values")
	if not FileAccess.file_exists(global_save_path):
		return
	var global_file = FileAccess.open(global_save_path, FileAccess.READ)
	#global_save.get_line() #skip first line
	var global_json = global_file.get_line()
	var json = JSON.new()
	var parse_result = json.parse(global_json)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", global_json, " at line ", json.get_error_line())
		return
	var node_data = json.data
	for i in node_data.keys():
		if typeof(node_data[i])  == TYPE_ARRAY || typeof(node_data[i])  == TYPE_DICTIONARY:
			global_save[i].assign(node_data[i])
		else:
			global_save[i] = node_data[i]
		
	
func _load_printers() -> void:
	for printer_resource_path in game_db.printers:
		var printer_res = load(printer_resource_path)
		#
		printers[printer_res.name] = printer_res
	
func _load_characters() -> void:
	for character_path in game_db.characters:
		
		var char_res = load(character_path)
		print("loading " + char_res.name)
		characters[char_res.name] = char_res
		
func get_char_fullname(name: String):
	if characters[name].full_name == "":
		return characters[name].display_name
	else:
		return characters[name].full_name
		
func get_character_icon(_id: String, _appearance: String):
	if !characters.has(_id):
		push_warning("ID %s is not a character!" % [_id])
		return
	if characters[_id].icon_resources.keys().has(_appearance):
		return characters[_id].icon_resources[_appearance]
	#elif _appearance == "" && _current_icon != "":
	#	return characters[_id].icon_resources[_current_icon]
	else:
		if _appearance != "": push_warning("Character %s does not have icon %s!" % [_id, _appearance])
		return characters[_id].icon_resources[characters[_id].DefaultSprite]
	
func get_default_icon(_id: String):
	return get_character_icon(_id, "Default")
	
func create_new_save(player_name: String, slot: int):
	print("New file for " + player_name + " created at slot " + str(slot))
	ingame_variables["zenith_name"] = "[" + player_name.to_upper() + "]"
	var new_save = PlayerSave.new()
	
	new_save.player_name = player_name
	new_save.file_index = slot
	#new_save.auto_save = GameSave.new()
	global_save.player_names[slot] = player_name
	global_save.player_saves[player_name] = create_player_files(new_save)
	global_save.current_player_slot = slot
	player_save = new_save
	#create_player_files(new_save)
	
	save_global()
	
	
	
	#var dir = DirAccess.open("user://" + game_name)
	#dir.make_dir(player_name)
	##global_save.player_saves.append(new_save)
	#dir.change_dir(player_name)
	#dir.make_dir("Manual Saves")
	#dir.make_dir("Point Saves")
	#var file = FileAccess.open(dir + "", FileAccess.WRITE)
	#file.store_string("test global data")
	#file.close()

func create_first_autosave(dir: DirAccess, save:PlayerSave):
	save.main_save = GameSave.new()
	var auto_data = FileAccess.open(dir.get_current_dir()+"/auto.json", FileAccess.WRITE)
	auto_data.store_line(JSON.stringify(save.main_save.main_to_json().data))
	auto_data.close()
	return dir.get_current_dir()+"/auto.json"
	
func create_player_files(save: PlayerSave):
	var dir = DirAccess.open("user://" + game_name)
	dir.make_dir(save.player_name)
	#global_save.player_saves.append(new_save)
	dir.change_dir(save.player_name)
	dir.make_dir("Manual Saves")
	dir.make_dir("Point Saves")
	dir.make_dir("Screenshots")
	save.auto_save_json = create_first_autosave(dir, save)
	var save_data = FileAccess.open(dir.get_current_dir()+"/player.json", FileAccess.WRITE)
	save_data.store_line(JSON.stringify(save.main_to_json().data))
	save_data.close()
	return dir.get_current_dir()+"/player.json"
	
	
func load_game_save():
	global_save.current_player_slot = player_save.file_index
	var json = FileAccess.open(player_save.auto_save_json, FileAccess.READ)
	player_save.main_save = player_save.load_game_save(json)
	current_scene_status = SceneTypes.in_game
	custom_global_data.roster_stats = player_save.main_save.voyager_status
	ingame_variables = player_save.main_save.variables
	
	
func get_screenshot(file_name: String):
	var sshot = get_viewport().get_texture().get_image()
	sshot.save_webp("user://"+game_name+"/"+global_save.get_current_save_name()+"/Screenshots/"+file_name+".webp")
	#sshot.save_webp_to_buffer(true)
	#sshot.save_png("user://"+game_name+"/"+global_save.get_current_save_name()+"/Screenshots/"+file_name+".png")
	
func save_global() -> void:
	var global_data = FileAccess.open(global_save_path, FileAccess.WRITE)
	global_data.store_line(
		JSON.stringify(global_save.main_to_json().data)
	)
	global_data.close()
	
func _process(delta: float) -> void:
	
	if(current_scene_status == SceneTypes.in_game):
		GlobalData.player_save.player_time_spent += delta
#		print(get_current_player_save().player_name +" - " +str(get_current_player_save().player_time_spent))
	#time += delta
	
func get_player_file_at(index: int):
	
	return global_save.player_names[index]
	
	
func save_player_file():
	var player_data = FileAccess.open("user://"+game_name+"/"+player_save.player_name+"/player.json", FileAccess.WRITE)
	player_data.store_line(
		JSON.stringify(player_save.main_to_json().data)
	)
	player_data.close()
#func save():
	#var save_dict = {
		#"one": 1
	#}
	#return save_dict

#func save_game():
	#var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	#var json_string = JSON.stringify(save())
	#save_file.store_line(json_string)

func current_file_path():
	return  "user://" + game_name + "/" + global_save.get_current_save_name()

func local_file_path():
	return  game_name + "/" + global_save.get_current_save_name()

func pause_printer():
	printer_paused = true
	auto_timer = 0.0

#func load_options(database : VN_Database):
	##wait_by_default = database.wait_by_default
	#pass


	#Settings.settings_options.to_j

func _set_tts_voices():
	# One-time steps.
	# Pick a voice. Here, we arbitrarily pick the first English voice.
	Settings.tts_voices = DisplayServer.tts_get_voices_for_language("en")
	print(Settings.tts_voices)
	#Settings.current_tts_voice = Settings.tts_voices[0]
	Settings.settings_options.current_tts_voice = 0 #set to default voice late

func tts_speak(line: String):

	# Say "Hello, world!".
	DisplayServer.tts_stop()
	if(Settings.settings_options.tts_toggle):
		DisplayServer.tts_speak(
			line, Settings.tts_voices[Settings.get_current_tts_voice()], int(Settings.settings_options.voice_volume)
		)

	#await get_tree().create_timer(1).timeout
#
	## Say a longer sentence, and then interrupt it.
	## Note that this method is asynchronous: execution proceeds to the next line immediately,
	## before the voice finishes speaking.
	#var long_message = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur"
	#DisplayServer.tts_speak(long_message, current_tts_voice)
	#
	##await get_tree().create_timer(1).timeout
#
	## Immediately stop the current text mid-sentence and say goodbye instead.
	##DisplayServer.tts_stop()
	#DisplayServer.tts_speak("Goodbye!", current_tts_voice)
