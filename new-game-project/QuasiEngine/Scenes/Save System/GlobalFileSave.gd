extends RefCounted
class_name GlobalSave

#things that are saved across all files. this is things like


#settings


var player_saves : Array[PlayerSave] = [null,null,null]
@export var current_player_slot := -1
var current_settings: SettingsOptions


class SettingsOptions:
	var main_volume = 50.0	
