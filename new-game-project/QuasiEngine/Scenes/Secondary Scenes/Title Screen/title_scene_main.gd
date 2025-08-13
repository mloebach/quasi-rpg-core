extends Node2D

@onready var popup_menu_stage = $"Upper Layer/Popup Stage"

@onready var start_screen = $"Main Layer/StartScreen"
@onready var file_select_button = $"Main Layer/StartScreen/ButtonsHBox/Start Buttons/MarginContainer/VBoxContainer/FilesButton"
@onready var autoload_stage = $"Main Layer/Autoload Stage"

@onready var file_screen = $"Main Layer/FileScreen"
@onready var file_screen_stage = $"Main Layer/FileScreen/Menu Stage"
@onready var file_screen_menu = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/file_manager_menu.tscn")

@onready var episode_select_menu = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/episode_selector_menu.tscn")

@onready var quit_menu = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/choice_popup_menu.tscn")

@export var quit_disclaimer_string : String = "Are you sure you would like to quit!?"


#@onready var file_menu = $"Main Layer/FileScreen/FileManager/UpperTitle/PanelContainer/FileSelectVBox"
#@onready var file_menu_lower = $"Main Layer/FileScreen/FileManager/LowerTitle/ChosenFileLower"
#@onready var new_game_menu = $"Main Layer/FileScreen/FileManager/UpperTitle/PanelContainer/NewGameVBox"
#@onready var chosen_file_menu = $"Main Layer/FileScreen/FileManager/UpperTitle/PanelContainer/ChosenFileVBox"
#@onready var chosen_file_lower_menu = $"Main Layer/FileScreen/FileManager/LowerTitle/ChosenFileLower"

#@export var current_player_file : PlayerSave
#var current_player_file_index : int = -1


signal switch_scene


func _ready() -> void:
	_default_visibilty()

func _default_visibilty() -> void:
	start_screen.visible = true
	file_screen.visible = false
	#quit_menu.visible = false
	#file_menu.visible = false
	#file_menu_lower.visible = false
	#new_game_menu.visible = false
	#chosen_file_menu.visible = false
	#chosen_file_lower_menu.visible = false
	
	if GlobalData.global_save.current_player_slot == -1:
		file_select_button.visible = false
	else:
		file_select_button.visible = true

func _on_quit_button_pressed() -> void:
	var new_popup = quit_menu.instantiate()
	popup_menu_stage.add_child(new_popup)
	new_popup.update_text(quit_disclaimer_string)
	new_popup.pop_up_confirm.connect(_on_quit_confirm_pressed)



func _on_quit_confirm_pressed() -> void:
	get_tree().quit()


func _on_quit_no_button_pressed() -> void:
	quit_menu.visible = false


func _on_new_game_button_button_up() -> void:
	if GlobalData.global_save.current_player_slot == -1:
		_on_files_button_button_up()
	else:
		start_screen.visible = false
		_create_autoload_menu()
	
func _create_menu() -> Node:
	var file_menu = file_screen_menu.instantiate()
	file_menu.return_to_title.connect(_on_return_to_title)
	return file_menu
	
func _create_file_menu() -> void:
	#var file_menu = file_screen_menu.instantiate()
	#var file_menu = episode_select_menu.instantiate()
	var file_menu = _create_menu()
	file_screen_stage.add_child(file_menu)
	
	#_switch_to_main_file_menu()
	
func _create_autoload_menu() -> void:
	var file_menu = _create_menu()
	autoload_stage.add_child(file_menu)
	#file_menu.return_to_title.connect(_on_return_to_title)
	file_menu.load_autoload(GlobalData.get_current_player_save())
	
	
	
func _on_return_to_title() -> void:
	_kill_autoload_objects()
	_kill_filescreen_objects()
	start_screen.visible = true
	
func _kill_autoload_objects() -> void:
	for item in autoload_stage.get_children():
		item.queue_free()
	
func _kill_filescreen_objects() -> void:
	for item in file_screen_stage.get_children():
		item.queue_free()
	file_screen.visible = false
#func _switch_to_main_file_menu() -> void:
	#file_menu.visible = true
	#file_menu_lower.visible = true
	#new_game_menu.visible = false
	#chosen_file_lower_menu.visible = false
	#chosen_file_menu.visible = false
	
	


func _on_files_button_button_up() -> void:
	start_screen.visible = false
	file_screen.visible = true
	_create_file_menu()
