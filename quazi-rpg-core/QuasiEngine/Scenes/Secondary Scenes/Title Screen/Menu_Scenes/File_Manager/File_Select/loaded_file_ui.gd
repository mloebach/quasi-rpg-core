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
signal load_to_save_menu

#signal swap_to_new_player_menu
var file_menu_mode : FileManagerMenu.FileMenuMode
var loaded_file : PlayerSave = PlayerSave.new()



func _ready() -> void:
	#_load_file(loaded_file)
	pass

func load_file(player_save : PlayerSave):
	#GlobalData.global_save.current_player_slot = player_save.file_index
	GlobalData.player_save = player_save
	file_number_text.text = "FILE " + "#"
	player_name_text.text = player_save.player_name
	time_played_text.text = Util.float_to_time_string(player_save.player_time_spent, true)
	var json = FileAccess.open(player_save.auto_save_json, FileAccess.READ)
	var auto = player_save.load_game_save(json)
	last_date_played_text.text = auto.date_saved
	quest_text.text = auto.current_quest
	location_text.text = auto.current_location

#	save_thumbnail.texture = player_save.auto_save.thumbnail
#come back to the above
	loaded_file = player_save

func _on_return_button_button_up() -> void:
	GlobalData.player_save = null
	#GlobalData.global_save.current_player_slot = -1
	if file_menu_mode == FileManagerMenu.FileMenuMode.Load:
		swap_to_file_select_menu.emit()
	elif file_menu_mode == FileManagerMenu.FileMenuMode.Autoload:
		return_to_title.emit()

func set_loaded_file(player_save : PlayerSave):
	loaded_file = player_save


func _on_continue_button_button_up() -> void:
	#load_selected_file.emit(loaded_file)
	load_selected_file.emit(loaded_file)

func _on_load_button_button_up() -> void:
	load_to_save_menu.emit(file_menu_mode)
