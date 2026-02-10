extends RefCounted
class_name PlayerSave

#saves things like...

#Player Name / File Name
#Played time
#Unlocked Wiki entries
#unlocked cgs
#associated saves
#unlocked episodes
#unlocked chapters of episodes
	
var player_name : String
var player_time_spent : float
var file_index : int
#@export var player_last_save_date = ""
var ng_plus_unlocked := false

var main_save : GameSave
var auto_save_json: String #reference to json
var point_saves: Array[GameSave] = [null,null,null]
var game_saves : Dictionary[String, String] #digit 1 = page, digit 2 = slot
var game_save_page: int = 1

var z_renames_left := 2
var z_color : String = Color.SLATE_GRAY.to_html()
var z_pronouns : Zenith_Global_Data.Pronouns =  Zenith_Global_Data.Pronouns.They

var unlocked_episodes : Dictionary[String, bool] = {
	#"Prelude" : true,
	"Prologue" : false,
	"Ep1" : false
}

func load_save(opened_json: FileAccess) -> PlayerSave:
	var new_save = PlayerSave.new()
	var save_json = opened_json.get_line()
	var json = JSON.new()
	var parse_result = json.parse(save_json)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", save_json, " at line ", json.get_error_line())
		return
	var node_data = json.data
	for i in node_data.keys():
		if typeof(node_data[i])  == TYPE_ARRAY || typeof(node_data[i])  == TYPE_DICTIONARY:
			new_save[i].assign(node_data[i])
		else:
			new_save[i] = node_data[i]
	return new_save


func load_game_save(opened_json: FileAccess) -> GameSave:
	var new_save = GameSave.new()
	var save_json = opened_json.get_line()
	var json = JSON.new()
	var parse_result = json.parse(save_json)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", save_json, " at line ", json.get_error_line())
		return
	var node_data = json.data
	for i in node_data.keys():
		if typeof(node_data[i])  == TYPE_ARRAY || typeof(node_data[i])  == TYPE_DICTIONARY:
			new_save[i].assign(node_data[i])
		else:
			new_save[i] = node_data[i]
	return new_save
	
	
func main_to_json() ->JSON:
	var save_dict = {
		"player_name" : player_name,
		"player_time_spent" : player_time_spent,
		"file_index" : file_index,
		"unlocked_episodes" : unlocked_episodes,
		"ng_plus_unlocked": ng_plus_unlocked,
		"auto_save_json": auto_save_json,
		"point_saves": point_saves,
		"game_saves": game_saves,
		"game_save_page": game_save_page,
		"z_renames_left": z_renames_left,
		"z_color": z_color,
		"z_pronouns": z_pronouns,
	}
	return Util.to_json(save_dict)


#func _init() -> void:
	#_base_auto_save()
#
#func _base_auto_save():
	#var first_auto_save = GameSave.new()
	#first_auto_save.current_location = "The Spring"
	#first_auto_save.current_quest = "Prelude"
	#first_auto_save.date_saved = Time.get_date_string_from_system()
	#auto_save = first_auto_save
