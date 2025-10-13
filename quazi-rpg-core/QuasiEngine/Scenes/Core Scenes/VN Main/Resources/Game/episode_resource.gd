extends Resource
class_name  Episode_Resource

@export var main_title : String
@export var number : int
##Refers to episodes that are later parts of other episodes - Ex Atlantis and Olympus
@export var level : int = 1
@export var episode_title: String #overrides "episode #"
@export var select_background: Texture2D

func get_episode_name():
	if episode_title == "":
		if level > 1:
			return "Episode_" + str(number) + "_" + str(level)
		return "Episode_" + str(number)
	else:
		return episode_title.replace(" ", "_")
