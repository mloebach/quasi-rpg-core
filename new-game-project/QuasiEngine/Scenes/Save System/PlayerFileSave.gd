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
	
@export var player_name : String
@export var player_time_spent : float
var file_index : int
#@export var player_last_save_date = ""

var auto_save: GameSave
var point_saves: Array[GameSave] = [null,null,null]
var game_saves : Dictionary[int, GameSave]

var unlocked_episodes : Dictionary[String, bool] = {
	"Prelude" : true,
	"Prologue" : false,
	"Ep1" : false
}




#move these to player save


var ng_plus_unlocked := false

func _init() -> void:
	_base_auto_save()

func _base_auto_save():
	var first_auto_save = GameSave.new()
	first_auto_save.current_location = "The Spring"
	first_auto_save.current_quest = "Prelude"
	first_auto_save.date_saved = Time.get_date_string_from_system()
	auto_save = first_auto_save
