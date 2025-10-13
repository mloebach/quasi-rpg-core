extends VBoxContainer

signal switch_to_file_select
signal load_chosen_episode

var current_episode = "Prelude"

@onready var episode_label = $UpperTitle/EpisodeScroll/HBoxContainer/VBoxContainer/TextureRect/MarginContainer/VBoxContainer/EpisodeLabel
@onready var title_label = $UpperTitle/EpisodeScroll/HBoxContainer/VBoxContainer/TextureRect/MarginContainer/VBoxContainer/TitleLabel
@onready var background = $UpperTitle/EpisodeScroll/HBoxContainer/VBoxContainer/TextureRect

@onready var upper_level_button = $UpperTitle/EpisodeScroll/HBoxContainer/VBoxContainer/SidestoryButton/Button
@onready var lower_level_button = $UpperTitle/EpisodeScroll/HBoxContainer/VBoxContainer/SidestoryButton2/Button

var current_index: float = 0.0
var episode_cap: float = 0.0

#matrix
var loadable_episodes: Dictionary[float, Episode_Resource]

func _ready() -> void:
	load_episodes()
	update_episode_ui()

func load_episodes() -> void:
	#var index := 0
	for episode in GlobalData.custom_global_data.episode_list:
		if GlobalData.custom_global_data.episode_list[episode].unlocked:
			var level_index : float = GlobalData.custom_global_data.episode_list[episode].episode_res.number
			if GlobalData.custom_global_data.episode_list[episode].episode_res.level > 1:
				level_index += ((GlobalData.custom_global_data.episode_list[episode].episode_res.level-1) / 10.0)
			if GlobalData.custom_global_data.episode_list[episode].episode_res.number > episode_cap:
				episode_cap = float(GlobalData.custom_global_data.episode_list[episode].episode_res.number)
			loadable_episodes[level_index] = GlobalData.custom_global_data.episode_list[episode].episode_res
				#if loadable_episodes.values().has()
			#else:
				#loadable_episodes[index] = GlobalData.custom_global_data.episode_list[episode].episode_res
				#index+=1
	

func update_episode_ui() -> void:
	episode_label.text = loadable_episodes[current_index].get_episode_name().capitalize()
	title_label.text = loadable_episodes[current_index].main_title
	background.texture = loadable_episodes[current_index].select_background
	
	if loadable_episodes.has(current_index+0.1):
		print("Sidestory Sensed")
		upper_level_button.visible = true
	else:
		upper_level_button.visible = false
		
	if loadable_episodes.has(current_index-0.1):
		lower_level_button.visible = true
	else:
		lower_level_button.visible = false
		

func _on_back_button_button_up() -> void:
	switch_to_file_select.emit()


func _on_start_button_pressed() -> void:
	load_chosen_episode.emit(current_episode)


func _on_prev_button_button_up() -> void:
	print("moving back one ep!")
	current_index = floorf(current_index)
	if current_index > 0:
		current_index = iterate_episodes(current_index, -1.0)
		update_episode_ui()


func _on_next_button_button_up() -> void:
	print("moving forward one ep!")
	current_index = floorf(current_index)
	if current_index < episode_cap:
		current_index = iterate_episodes(current_index, 1.0)
		update_episode_ui()

func iterate_episodes(index: float, multiplier: float) -> float:
	print("index " + str(index))
	index += (1.0 * multiplier)
	if (index) < 0.0 || index > episode_cap:
		print("aborting!")
		return current_index
	if loadable_episodes.has(index):
		return index
	else:
		print("going further!!")
		return iterate_episodes(index, multiplier)


func _on_button_button_up() -> void:
	print("moving up one level!")
	if loadable_episodes.has(current_index+0.1):
		current_index += 0.1 
	update_episode_ui()


func _on_lower_level_button_button_up() -> void:
	print("moving down one level!")
	if loadable_episodes.has(current_index-0.1):
		current_index -= 0.1 
	update_episode_ui()
