#data that persists between scenes

extends Node

#we're putting the story trees here so we don't need to do it over and over

var global_save : GlobalSave = preload("res://QuasiEngine/Scenes/_Debug/Test_saves/test_global.tres")

var script_data_loaded : bool = false
var script_trees : Dictionary [String, String] = {
	
}

#GAME OPTIONS
var wait_by_default = true

func get_current_player_save() -> PlayerSave:
	return global_save.player_saves[global_save.current_player_slot]

func load_options(database : VN_Database):
	wait_by_default = database.wait_by_default
	pass
