#data that persists between scenes

extends Node

#we're putting the story trees here so we don't need to do it over and over

var script_data_loaded : bool = false
var script_trees : Dictionary [String, String] = {
	
}

#GAME OPTIONS
var wait_by_default = true


func load_options(database : VN_Database):
	wait_by_default = database.wait_by_default
	pass
