extends Control
class_name FileManagerMenu

#@onready var file_select_menu = $UpperTitle/PanelContainer/FileSelectVBox
@onready var file_select_lower = $VBox/LowerTitle/LowerBox
#@onready var new_game_menu = $UpperTitle/PanelContainer/NewGameVBox
#@onready var chosen_file_menu = $UpperTitle/PanelContainer/ChosenFileVBox
@onready var chosen_file_lower =  $VBox/LowerTitle/ChosenFileLower


#@onready var main_stage_vbox = $UpperTitle/PanelContainer/MainStageVbox
@onready var popup_stage = $"Popup Stage"

#@onready var name_text_field = $"UpperTitle/PanelContainer/NewGameVBox/MarginContainer/SaveContainer/Name Field/Control/NameField"
@onready var ng_plus_button =  $VBox/LowerTitle/ChosenFileLower/NGButton

#@onready var file_button_vbox = $"UpperTitle/PanelContainer/FileSelectVBox/MarginContainer/SaveContainer/VBoxContainer/File Stage"
@onready var ui_stage =  $VBox/UpperTitle/PanelContainer/MainStageVbox/StageMargins
@onready var file_text =  $VBox/UpperTitle/PanelContainer/MainStageVbox/TextMargins/FileText

@onready var chosen_file_menu = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/File_Select/loaded_file_ui.tscn")
@onready var new_game_menu = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/File_Select/new_game_ui.tscn")
@onready var file_select_menu = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/File_Select/file_select_ui.tscn")
@onready var popup_menu = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/choice_popup_menu.tscn")
#@onready var file_button = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/File_Select/file_button.tscn")

@export var file_select_string = "	Please select a file."
@export var chosen_file_string = "	Open this file?"
@export var new_game_string = "	Please type your name."

@export var title_screen_disclaimer_string = "Do you want to return to the title screen?"


#var file_menu_mode : FileMenuMode

signal return_to_title

enum FileMenuMode {
	Autoload,
	Load
}

func load_autoload(current_file : PlayerSave):
	_swap_to_autoload(current_file)

func _ready() -> void:
	_default_visibilty()
	

func _default_visibilty() -> void:
	_swap_to_file_select()
	
	
#func _load_file_buttons() -> void:
	#for index in GlobalData.global_save.player_saves.size():
		#var save_button = file_button.instantiate()
		#file_button_vbox.add_child(save_button)
		#save_button.set_file_number((index+1))
		#save_button.file_selected.connect(_on_file_selected)
		#
		#if(GlobalData.global_save.player_saves[index] != null):
			##print(GlobalData.global_save.player_saves[index])
			#save_button.load_file_info(GlobalData.global_save.player_saves[index])
		


#func _unload_file_buttons() -> void:
	#for button in file_button_vbox.get_children():
		#button.queue_free()
		
func _unload_current_menu() -> void:
	for file in ui_stage.get_children():
		file.queue_free()
		
#func _on_file_selected(file_button : PlayerFileButton):
	#if file_button.file_status == PlayerFileButton.FileStatus.SavedFile:
		#_swap_to_load(file_button.player_file)
	#elif file_button.file_status == PlayerFileButton.FileStatus.NewFile:
		##print("new file!")
		#_swap_to_new()
	
func _swap_to_file_select() -> void:
	#file_select_menu.visible = true
	file_select_lower.visible = true
	#new_game_menu.visible = false
	chosen_file_lower.visible = false
	#chosen_file_menu.visible = false
	_unload_current_menu()
	var file_select = file_select_menu.instantiate()
	ui_stage.add_child(file_select)
	file_select.swap_to_load_player_menu.connect(_swap_to_load)
	file_select.swap_to_new_player_menu.connect(_swap_to_new)
	file_text.text = file_select_string
	
	
	#_load_file_buttons()
	

func _swap_to_load(player_file : PlayerSave) -> Node:
	#file_select_menu.visible = false
	file_select_lower.visible = false
	#new_game_menu.visible = false
	chosen_file_lower.visible = true
	#chosen_file_menu.visible = true
	_unload_current_menu()
	
	var file_info = _load_file_info(player_file)
	file_info.file_menu_mode = FileMenuMode.Load

	file_text.text = chosen_file_string
	
	return file_info
	#_unload_file_buttons()
	
func _load_file_info(player_save: PlayerSave) -> Node:
	var file_info = chosen_file_menu.instantiate()
	ui_stage.add_child(file_info)
	file_info.swap_to_file_select_menu.connect(_swap_to_file_select)
	file_info.return_to_title.connect(_on_return_to_title)
	if player_save.ng_plus_unlocked:
		ng_plus_button.visible = true
	else:
		ng_plus_button = false
	return file_info
	
func _swap_to_new() -> void:
	#file_select_menu.visible = false
	file_select_lower.visible = false
	#new_game_menu.visible = true
	chosen_file_lower.visible = false
	#chosen_file_menu.visible = false
	#_unload_file_buttons()
	_unload_current_menu()
	var new_menu = new_game_menu.instantiate()
	ui_stage.add_child(new_menu)
	#new_game_menu.swap_to_load_player_menu.connect(_swap_to_load)
	new_menu.swap_to_file_select_menu.connect(_swap_to_file_select)
	file_text.text = new_game_string
	


func _swap_to_autoload(current_file : PlayerSave) -> void:
	var file_menu = _swap_to_load(current_file)
	file_menu.file_menu_mode = FileMenuMode.Autoload
	chosen_file_lower.visible = false


func _on_return_to_title():
	return_to_title.emit()

#func _on_new_reset_button_button_up() -> void:
	#name_text_field.text = ""


#func _on_new_menu_return_button_button_up() -> void:
	#_swap_to_file_select()


#func _on_return_button_button_up() -> void:
	#if file_menu_mode == FileMenuMode.Load:
		#_swap_to_file_select()
	#elif file_menu_mode == FileMenuMode.Autoload:
		#return_to_title.emit()


func _on_title_button_button_up() -> void:
	var new_popup = popup_menu.instantiate()
	popup_stage.add_child(new_popup)
	new_popup.update_text(title_screen_disclaimer_string)
	new_popup.pop_up_confirm.connect(_on_return_to_title)

#func _on_title_confirm_pressed() -> void:
	#pass
