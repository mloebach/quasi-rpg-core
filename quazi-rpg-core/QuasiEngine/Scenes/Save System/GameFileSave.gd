extends RefCounted
class_name GameSave

#saves current state of game. saves things like


#variables
#makeup of current scene
#current scene and line

@export var thumbnail : Texture2D

var script_name : String
var script_index : int = 0

var active_printer : String = ""

var current_location := ""
var current_quest := ""

var date_saved = ""

var variables := {} 
var voyager_status := {}


func _init() -> void:
	script_name = GlobalData.opening_script
	script_index = 0
	current_location = GlobalData.starting_location
	current_quest = GlobalData.starting_quest
	date_saved = Time.get_datetime_string_from_system(false, true)
	variables = GlobalData.ingame_variables
	voyager_status = GlobalData.custom_global_data.roster_stats
	#current_location = 

#func load_save(opened_json: FileAccess) -> GameSave:
	#var new_save = GameSave.new()
	#var save_json = opened_json.get_line()
	#var json = JSON.new()
	#var parse_result = json.parse(save_json)
	#if not parse_result == OK:
		#print("JSON Parse Error: ", json.get_error_message(), " in ", save_json, " at line ", json.get_error_line())
		#return
	#var node_data = json.data
	#for i in node_data.keys():
		#if typeof(node_data[i])  == TYPE_ARRAY || typeof(node_data[i])  == TYPE_DICTIONARY:
			#new_save[i].assign(node_data[i])
		#else:
			#new_save[i] = node_data[i]
	#return new_save

func main_to_json() ->JSON:
	var save_dict = {
		"script_name" : script_name,
		"script_index" : script_index,
		"current_location" : current_location,
		"current_quest" : current_quest,
		"date_saved" : date_saved,
		"variables" : variables,
		"active_printer" : active_printer,
		"voyager_status" : voyager_status
	}
	return Util.to_json(save_dict)
