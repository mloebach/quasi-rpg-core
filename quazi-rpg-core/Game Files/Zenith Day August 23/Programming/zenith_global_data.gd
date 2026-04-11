extends RefCounted
class_name Zenith_Global_Data

#var roster_stats: Dictionary[String, CharacterStatus]
var episode_list: Dictionary[String, Episode]
#var zenith_pronoun: Pronouns = Pronouns.He

func _init() -> void:
	#init_roster_stats()
	init_episode_list()


func init_episode_list() -> void:
	for episode in GlobalData.game_db.episodes:
		print("loading episode " + episode.get_episode_name())
		episode_list[episode.get_episode_name()] = Episode.new(episode)

#func init_roster_stats() -> void:
	#for character in GlobalData.characters:
		#print("checking character in global data!")
		#if GlobalData.characters[character].tags.has("Voyager"):
			##roster_stats[character] = (StatusChar.new(GlobalData.characters[character]))
			#roster_stats[character] = CharacterStatus.Locked

#func get_char_status(name: String):
	#return roster_stats[name]
##

func z_pro(pronoun:String) -> String:
	var pro :=  get_z_pro(pronoun.to_lower())
	if Util.is_char_lower(pronoun[0]): #if first character is lower assume all of them are
		return pro
	else:
		if Util.is_word_upper(pronoun):
			return Util.capitalize_full_string(pro)#capitalized word
		else:
			return Util.capitalize_string(pro)
	
func get_z_pro(pronoun:String) -> String:
	match pronoun:
		"they":
			return pronoun_tree("they", "he", "she")
			#match GlobalData.player_save.z_pronouns:
				#Pronouns.They:
					#return "they"
				#Pronouns.He:
					#return "he"
				#Pronouns.She:
					#return "they"
				#_:
					#return ""
		"them":
			return pronoun_tree("them", "him", "her")
			#match GlobalData.player_save.z_pronouns:
				#Pronouns.They:
					#return "them"
				#Pronouns.He:
					#return "him"
				#Pronouns.She:
					#return "her"
				#_:
					#return ""
		"their":
			return pronoun_tree("their", "his", "her")
			#match GlobalData.player_save.z_pronouns:
				#Pronouns.They:
					#return "their"
				#Pronouns.He:
					#return "his"
				#Pronouns.She:
					#return "her"
				#_:
					#return ""
		"theirs":
			#match GlobalData.player_save.z_pronouns:
			return pronoun_tree("theirs", "his", "hers")
				#Pronouns.They:
					#return "theirs"
				#Pronouns.He:
					#return "his"
				#Pronouns.She:
					#return "hers"
				#_:
					#return ""
		"themselves", "themself":
			return pronoun_tree(pronoun, "himself", "herself")
			#match GlobalData.player_save.z_pronouns:
				#Pronouns.They:
					#return pronoun
				#Pronouns.He:
					#return "himself"
				#Pronouns.She:
					#return "herself"
				#_:
					#return ""
		"are they":
			return pronoun_tree("are they", "is he", "is she")
		"they are":
			return pronoun_tree("they are", "he is", "she is")
		"they're":
			return pronoun_tree("they're", "he's", "she's")
		_:
			push_error("Unknown pronoun used in script - " + pronoun)
			return ""
		
func pronoun_tree(they: String, he: String, she: String) -> String:
	match GlobalData.player_save.z_pronouns:
		Pronouns.They:
			return they
		Pronouns.He:
			return he
		Pronouns.She:
			return she
		_:
			return ""


class StatusChar:
	var name: String
	var icon: Texture2D
	var status: CharacterStatus
	
	func _init(_character : Char_Resource):
		name = _character.name
		icon = _character.icon_resources["Default"]
		status = CharacterStatus.Locked
	
	func _to_string() -> String:
		return "{" + name + ":" + str(status) +	"}"
		
	
enum CharacterStatus{
	Active, #currently running participant in game
	Eliminated, #ejected from game
	Locked, #we haven't met them yet
	Unknown
}

enum Pronouns{
	They,
	He,
	She
}

class Episode:
	var episode_res : Episode_Resource
	var unlocked := true
	
	func _init(_episode: Episode_Resource):
		episode_res = _episode
