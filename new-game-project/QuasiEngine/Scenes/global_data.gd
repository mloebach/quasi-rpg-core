#data that persists between scenes

extends Node

#we're putting the story trees here so we don't need to do it over and over

var global_save : GlobalSave = preload("res://QuasiEngine/Scenes/_Debug/Test_saves/test_global_fresh.tres")
var game_db: VN_Database = preload("res://Game Files/Zenith Day August 23/Database/z_game_database.tres")

var script_data_loaded : bool = false
var script_trees : Dictionary [String, String] = {
	
}

#GAME OPTIONS
#
var current_window_size_index : int


func get_current_player_save() -> PlayerSave:
	return global_save.player_saves[global_save.current_player_slot]
	
func create_new_save(player_name: String, slot: int):
	print("New file for " + player_name + " created at slot " + str(slot))
	global_save.current_player_slot = slot
	var new_save = PlayerSave.new()
	new_save.player_name = player_name
	#global_save.player_saves[slot] = new_save
	global_save.player_saves.append(new_save)
	

#func load_options(database : VN_Database):
	##wait_by_default = database.wait_by_default
	#pass
