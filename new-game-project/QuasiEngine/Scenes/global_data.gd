#data that persists between scenes

extends Node

#we're putting the story trees here so we don't need to do it over and over

#var global_save : GlobalSave = preload("res://QuasiEngine/Scenes/_Debug/Test_saves/test_global_fresh.tres")
var global_save : GlobalSave = GlobalSave.new()
var game_db: VN_Database = preload("res://Game Files/Zenith Day August 23/Database/z_game_database.tres")
var current_scene_status = SceneTypes.out_of_game
enum SceneTypes {
	in_game,
	out_of_game
}

var script_data_loaded : bool = false
var script_trees : Dictionary [String, SceneTranspiler.StoryTree] = {
	
}

var auto_printer_on := false
var auto_timer := 0.0
var auto_timer_wait := 1.5

#add variable restriction that makes it so certain variables are locked
#and cannot be edited by @set
var ingame_variables := {
	
}

var characters : Dictionary[String, Char_Resource] ={
	
}

var printers := {
	
}

#GAME OPTIONS
#
var current_window_size_index : int

func _ready() -> void:
	_load_printers()
	_load_characters()

func get_current_player_save() -> PlayerSave:
	return global_save.player_saves[global_save.current_player_slot]
	
func _load_printers() -> void:
	for printer_resource_path in game_db.printers:
		var printer_res = load(printer_resource_path)
		printers[printer_res.name] = printer_res
	
func _load_characters() -> void:
	for character_path in game_db.characters:
		
		var char_res = load(character_path)
		print("loading " + char_res.name)
		characters[char_res.name] = char_res
		
func get_character_icon(_id: String, _appearance: String):
	if characters[_id].icon_resources.keys().has(_appearance):
		return characters[_id].icon_resources[_appearance]
	#elif _appearance == "" && _current_icon != "":
	#	return characters[_id].icon_resources[_current_icon]
	else:
		if _appearance != "": push_warning("Character %s does not have icon %s!" % [_id, _appearance])
		return characters[_id].icon_resources[characters[_id].DefaultSprite]
	
func create_new_save(player_name: String, slot: int):
	print("New file for " + player_name + " created at slot " + str(slot))
	global_save.current_player_slot = slot
	var new_save = PlayerSave.new()
	new_save.player_name = player_name
	new_save.file_index = slot
	global_save.player_saves[slot] = new_save
	ingame_variables["zenith_name"] = "[" + player_name.to_upper() + "]"
	#global_save.player_saves.append(new_save)
	
func _process(delta: float) -> void:
	
	if(current_scene_status == SceneTypes.in_game):
		get_current_player_save().player_time_spent += delta
#		print(get_current_player_save().player_name +" - " +str(get_current_player_save().player_time_spent))
	#time += delta
	
func save():
	var save_dict = {
		"one": 1
	}
	return save_dict

func save_game():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var json_string = JSON.stringify(save())
	save_file.store_line(json_string)


#func load_options(database : VN_Database):
	##wait_by_default = database.wait_by_default
	#pass
