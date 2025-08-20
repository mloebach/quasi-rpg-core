extends Resource
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
#@export var player_last_save_date = ""

@export var auto_save: GameSave
@export var point_saves: Array[GameSave] = [null,null,null]
@export var game_saves : Dictionary[int, GameSave]

#move these to player save


var ng_plus_unlocked := false
