extends PanelContainer

@onready var file_number_text = $VBoxContainer/File/VBoxContainer/HBoxContainer/PanelContainer/FileNumber
@onready var player_name_text = $VBoxContainer/File/VBoxContainer/HBoxContainer/FakeButton/MarginContainer/FileInfo/HBoxContainer/Name
@onready var time_played_text = $VBoxContainer/File/VBoxContainer/HBoxContainer/FakeButton/MarginContainer/FileInfo/HBoxContainer/TimePlayed
@onready var last_date_played_text = $VBoxContainer/File/VBoxContainer/PanelContainer/VBoxContainer/AutoSaveRibbon/DateText
@onready var quest_text = $"VBoxContainer/File/VBoxContainer/PanelContainer/VBoxContainer/AutoSaveInfo/MarginContainer2/InfoDock/Quest Marker"
@onready var location_text = $VBoxContainer/File/VBoxContainer/PanelContainer/VBoxContainer/AutoSaveInfo/MarginContainer2/InfoDock/LocationText

@onready var save_thumbnail = $VBoxContainer/File/VBoxContainer/PanelContainer/VBoxContainer/AutoSaveInfo/MarginContainer/SaveThumbnail

signal swap_to_file_select_menu
signal return_to_title
signal load_selected_file


#signal swap_to_new_player_menu
var file_menu_mode : FileManagerMenu.FileMenuMode
var loaded_file : PlayerSave



func _ready() -> void:
	#_load_file(loaded_file)
	pass

func load_file(player_save : PlayerSave):
	file_number_text.text = "FILE " + "#"
	player_name_text.text = player_save.player_name
	time_played_text.text = Util.float_to_time_string(player_save.player_time_spent, true)
	last_date_played_text.text = player_save.auto_save.date_saved
	quest_text.text = player_save.auto_save.current_quest
	location_text.text = player_save.auto_save.current_location

	save_thumbnail.texture = player_save.auto_save.thumbnail
	loaded_file = player_save

func _on_return_button_button_up() -> void:
	if file_menu_mode == FileManagerMenu.FileMenuMode.Load:
		swap_to_file_select_menu.emit()
	elif file_menu_mode == FileManagerMenu.FileMenuMode.Autoload:
		return_to_title.emit()

func set_loaded_file(player_save : PlayerSave):
	loaded_file = player_save


func _on_continue_button_button_up() -> void:
	load_selected_file.emit(loaded_file)
