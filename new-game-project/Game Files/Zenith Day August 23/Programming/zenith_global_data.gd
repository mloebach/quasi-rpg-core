extends RefCounted
class_name Zenith_Global_Data

var roster_stats: Dictionary[String, StatusChar]
var episode_list: Dictionary[String, Episode]

func _init() -> void:
	init_roster_stats()
	init_episode_list()


func init_episode_list() -> void:
	for episode in GlobalData.game_db.episodes:
		print("loading episode " + episode.get_episode_name())
		episode_list[episode.get_episode_name()] = Episode.new(episode)

func init_roster_stats() -> void:
	for character in GlobalData.characters:
		print("checking character in global data!")
		if GlobalData.characters[character].tags.has("Voyager"):
			roster_stats[character] = (StatusChar.new(GlobalData.characters[character]))

func get_char_status(name: String):
	return roster_stats[name]

class StatusChar:
	var name: String
	var icon: Texture2D
	var status: CharacterStatus
	
	func _init(_character : Char_Resource):
		name = _character.name
		icon = _character.icon_resources["Default"]
		status = CharacterStatus.Active
	
	
enum CharacterStatus{
	Active,
	Eliminated,
	Unknown
}

class Episode:
	var episode_res : Episode_Resource
	var unlocked := true
	
	func _init(_episode: Episode_Resource):
		episode_res = _episode
