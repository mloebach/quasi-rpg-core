extends RefCounted
class_name GlobalSave

#things that are saved across all files. this is things like


#settings


var player_names : Array[String] = ["","",""]
#var player_saves : Dictionary[String, PlayerSave] = {}
#stores where json file is in memory
var player_saves : Dictionary[String, String] = {}
var current_player_slot := -1
var autoload_save_deleted := false
#var current_settings: SettingValues.SettingOptions = SettingValues.SettingOptions.new(Settings.default_res)

#func _init() -> void:
	#cur

#func get_current_save() -> PlayerSave:
func get_current_save() -> String:
	return player_saves[str(current_player_slot)+"_"+player_names[current_player_slot]]

#func get_save_at_slot(slot: int) -> PlayerSave:
func get_save_at_slot(slot: int) -> String:
	return player_saves[str(slot)+"_"+player_names[slot]]

func get_current_save_name() -> String:
	return player_names[current_player_slot]

#func to_json(save_dict: Dictionary) -> JSON:
	#var json = JSON.new()
	#var error = json.parse(JSON.stringify(save_dict))
	#if error == OK:
		#var data_recieved = json.data
		#if typeof(data_recieved) == TYPE_DICTIONARY:
			#print(data_recieved) # Prints the array.
		#else:
			#print("Unexpected data")
	#else:
		#print("JSON Parse Error: ", json.get_error_message(), " in ", JSON.stringify(save_dict), " at line ", json.get_error_line())
	#return json
	
func main_to_json() ->JSON:
	var save_dict = {
		"player_names" : player_names,
		"player_saves" : player_saves,
		"current_player_slot" : current_player_slot,
		"autoload_save_deleted" : autoload_save_deleted
	}
	return Util.to_json(save_dict)
	
#func settings_to_json() ->JSON:
	#return Util.to_json(current_settings.to_dict())
