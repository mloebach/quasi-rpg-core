extends Resource
class_name GameSave

#saves current state of game. saves things like


#variables
#makeup of current scene
#current scene and line

@export var thumbnail : Texture2D

@export var current_location := ""
@export var current_quest := ""

@export var date_saved = ""

var variables := {} 
