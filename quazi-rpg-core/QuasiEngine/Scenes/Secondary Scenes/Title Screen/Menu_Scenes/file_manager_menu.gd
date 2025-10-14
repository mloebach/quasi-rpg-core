extends Control
class_name FileManagerMenu

#@onready var file_select_menu = $UpperTitle/PanelContainer/FileSelectVBox
@onready var file_select_lower = $VBox/LowerTitle/LowerBox
#@onready var new_game_menu = $UpperTitle/PanelContainer/NewGameVBox
#@onready var chosen_file_menu = $UpperTitle/PanelContainer/ChosenFileVBox
@onready var chosen_file_lower =  $VBox/LowerTitle/ChosenFileLower
@onready var autoload_file_lower = $VBox/LowerTitle/AutoloadLower
@onready var cancel_lower = $VBox/LowerTitle/CancelBox


#@onready var main_stage_vbox = $UpperTitle/PanelContainer/MainStageVbox
@onready var popup_stage = $"Popup Stage"
@onready var settings_stage = $"Settings Stage"

#@onready var name_text_field = $"UpperTitle/PanelContainer/NewGameVBox/MarginContainer/SaveContainer/Name Field/Control/NameField"
@onready var ng_plus_button =  $VBox/LowerTitle/ChosenFileLower/NGButton

#@onready var file_button_vbox = $"UpperTitle/PanelContainer/FileSelectVBox/MarginContainer/SaveContainer/VBoxContainer/File Stage"
@onready var ui_stage =  $VBox/UpperTitle/PanelContainer/MainStageVbox/StageMargins
@onready var file_text =  $VBox/UpperTitle/PanelContainer/MainStageVbox/TextMargins/FileText

@onready var chosen_file_menu = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/File_Select/loaded_file_ui.tscn")
@onready var new_game_menu = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/File_Select/new_game_ui.tscn")
@onready var file_select_menu = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/File_Select/file_select_ui.tscn")
@onready var popup_menu = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/choice_popup_menu.tscn")
@onready var settings_menu = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/settings_menu.tscn")
#@onready var file_button = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/File_Select/file_button.tscn")

@export var file_select_string = "	Please select a file."
@export var chosen_file_string = "	Continue?"
@export var new_game_string = "	Please type your name."
@export var autoload_file_string = "	Would you like to continue?"

@export var title_screen_disclaimer_string = "Do you want to return to the title screen?"
@export var confirm_name_disclaimer_string = "Is this your name?"
@export var autosave_load_disclaimer_string = "Load Autosave?"

var current_file_index : int
var current_name : String
#var current_player_file : PlayerSave

var option_index: int = -1

#var file_menu_mode : FileMenuMode

signal return_to_title
signal load_into_file_menu
signal switch_scene
signal open_episode_select
signal load_save_menu
signal choose_erase_file
signal choose_copy_file
signal exit_to_normal
signal erase_selected_file

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
	autoload_file_lower.visible = false
	#chosen_file_menu.visible = false
	_unload_current_menu()
	var file_select = file_select_menu.instantiate()
	ui_stage.add_child(file_select)
	file_select.swap_to_load_player_menu.connect(_swap_to_load)
	file_select.swap_to_new_player_menu.connect(_swap_to_new)
	file_text.text = file_select_string
	choose_erase_file.connect(file_select._on_choose_erase_file)
	exit_to_normal.connect(file_select._on_exit_to_normal)
	choose_copy_file.connect(file_select._on_copy_mode_on)
	file_select.which_slot_to_copy.connect(_on_which_slot_to_copy)
	file_select.erase_selected_file.connect(_on_erase_selected_file)
	file_select.option_selected.connect(_on_exit_to_normal)
	
	#_load_file_buttons()
	

func _swap_to_load(player_file : PlayerSave, file_index: int) -> Node:
	#file_select_menu.visible = false
	file_select_lower.visible = false
	#new_game_menu.visible = false
	chosen_file_lower.visible = true
	autoload_file_lower.visible = false
	#chosen_file_menu.visible = true
	_unload_current_menu()
	
	var file_info = _load_file_info(player_file)
	file_info.file_menu_mode = FileMenuMode.Load

	file_text.text = chosen_file_string
	
	
	
	return file_info
	#_unload_file_buttons()
	
func _load_file_info(player_save: PlayerSave) -> Node:
	var file_info = chosen_file_menu.instantiate()
	#GlobalData.player_save = current_player_file #put this here
	GlobalData.player_save = player_save
	ui_stage.add_child(file_info)
	file_info.load_file(player_save)
	file_info.swap_to_file_select_menu.connect(_swap_to_file_select)
	file_info.return_to_title.connect(_on_return_to_title)
	file_info.load_selected_file.connect(_on_load_autosave_of_selected)
	file_info.load_to_save_menu.connect(_on_load_save_menu)
	if player_save.ng_plus_unlocked:
		ng_plus_button.visible = true
	else:
		ng_plus_button = false
	return file_info
	
func _swap_to_new(player_index: int) -> void:
	#file_select_menu.visible = false
	file_select_lower.visible = false
	#new_game_menu.visible = true
	chosen_file_lower.visible = false
	autoload_file_lower.visible = false
	#chosen_file_menu.visible = false
	#_unload_file_buttons()
	_unload_current_menu()
	var new_menu = new_game_menu.instantiate()
	ui_stage.add_child(new_menu)
	new_menu.load_file(player_index)
	#new_game_menu.swap_to_load_player_menu.connect(_swap_to_load)
	new_menu.swap_to_file_select_menu.connect(_swap_to_file_select)
	new_menu.start_new_file.connect(_on_start_new_file)
	file_text.text = new_game_string
	


func _swap_to_autoload(current_file : PlayerSave) -> void:
	var file_menu = _swap_to_load(current_file, GlobalData.global_save.current_player_slot)
	file_menu.file_menu_mode = FileMenuMode.Autoload
	file_text.text = autoload_file_string
	chosen_file_lower.visible = false
	autoload_file_lower.visible = true


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
		
func _on_load_autosave_of_selected(loaded_player_save : PlayerSave) -> void:
	GlobalData.player_save = loaded_player_save
	_create_popup(_load_game_file, 
		autosave_load_disclaimer_string
		)
		
func _create_popup(confirm_function : Callable, disclaimer_string: String = "") -> void:
	var new_popup = popup_menu.instantiate()
	popup_stage.add_child(new_popup)
	if(disclaimer_string != ""):
		new_popup.update_text(disclaimer_string)
	new_popup.pop_up_confirm.connect(confirm_function)

func _on_title_button_button_up() -> void:
	
	_create_popup(_on_return_to_title, title_screen_disclaimer_string)
	#var new_popup = popup_menu.instantiate()
	#popup_stage.add_child(new_popup)
	#new_popup.update_text(title_screen_disclaimer_string)
	#new_popup.pop_up_confirm.connect(_on_return_to_title)

#func _on_title_confirm_pressed() -> void:
	#pass


func _on_settings_button_button_up() -> void:
	var new_settings_menu = settings_menu.instantiate()
	settings_stage.add_child(new_settings_menu)
	


func _on_load_quit_button_button_up() -> void:
	_swap_to_file_select()


#func _on_autoload_quit_button_button_up() -> void:
	 #_on_return_to_title()


func _on_autoload_file_select_button_button_up() -> void:
	load_into_file_menu.emit()

func _on_start_new_file(player_name: String, slot_number: int) -> void:
	current_file_index = slot_number
	current_name = player_name
	_create_popup(_start_new_file, 
		"[b]" + player_name + "[/b]\n" + confirm_name_disclaimer_string
		)

func _start_new_file() -> void:
	#save player name to file in the correct slot
	#set current index in global save to new file
	#print("New file for " + current_name + " created at slot " + str(current_file_index))
	GlobalData.create_new_save(current_name, current_file_index)
	GlobalData.current_scene_status = GlobalData.SceneTypes.in_game
	switch_scene.emit("vn")
	
func _load_game_file() -> void:
	#GlobalData.player_save = current_player_file
	
	#var json = FileAccess.open(current_player_file.auto_save_json, FileAccess.READ)
	#GlobalData.player_save.main_save = current_player_file.load_game_save(json)
	
	GlobalData.load_game_save()
	
	
	switch_scene.emit("vn")


func _on_chapter_select_button_up() -> void:
	open_episode_select.emit()

func _on_load_save_menu(file_menu_mode: FileManagerMenu.FileMenuMode) -> void:
	load_save_menu.emit(file_menu_mode)
	#load_save_menu.swap_to_load_menu.connect(_swap_to_load)


func _on_copy_button_button_up() -> void:
	print("Copying file!")
	file_text.text = "	Copy which file?"
	choose_copy_file.emit()
	file_select_lower.hide()
	cancel_lower.show()

func _on_which_slot_to_copy(index: int) -> void:
	file_text.text = "	Copy File " + str(index) + " to which slot?"

func _on_erase_button_button_up() -> void:
	print("Erasing file!")
	file_text.text = "	Erase which file?"
	choose_erase_file.emit()
	file_select_lower.hide()
	cancel_lower.show()

func _on_erase_selected_file(index: int):
	option_index = index
	_create_popup(_erase_file, "Erase the data in File " + str(index) + "?")
	
	
func _erase_file():
	
	
	var folder = GlobalData.main_folder + GlobalData.global_save.player_names[option_index-1]
	print("erasing selected file! " + str(folder))
	if DirAccess.dir_exists_absolute(folder):
		remove_recursive(folder)
	
	_clear_popups()
	_on_exit_to_normal()


func remove_recursive(dir_path: String):
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				#recursively remove subdirectories
				remove_recursive(dir_path.path_join(file_name))
			else:
				#remove files
				DirAccess.remove_absolute(dir_path.path_join(file_name))
		dir.list_dir_end()
		#now remove empty directory
		DirAccess.remove_absolute(dir_path.path_join(file_name))
		print("Directory removed successfully!")
	else:
		push_error("An error occured while opening directory: " + dir_path)

func _on_cancel_button_button_up() -> void:
	print("Cancelling!")
	_on_exit_to_normal()
	#file_text.text = file_select_string
	#exit_to_normal.emit()
	#cancel_lower.hide()
	#file_select_lower.show()
	
func _clear_popups():
	for item in popup_stage.get_children():
		item.queue_free()
	
func _on_exit_to_normal():
	file_text.text = file_select_string
	exit_to_normal.emit()
	cancel_lower.hide()
	file_select_lower.show()
	
