extends HBoxContainer
class_name PlayerFileButton

@onready var new_game_text = $Button/MarginContainer/NewGameText
@onready var file_information = $Button/MarginContainer/FileInfo

@onready var name_text = $Button/MarginContainer/FileInfo/HBoxContainer/Name
@onready var player_time = $"Button/MarginContainer/FileInfo/HBoxContainer/Time Label"
@onready var location_label = $"Button/MarginContainer/FileInfo/HBoxContainer2/Quest Label"
@onready var date_label = $Button/MarginContainer/FileInfo/HBoxContainer2/DateText
@onready var file_number_text = $PanelContainer/FileNumber




var file_index: int
var file_status : FileStatus
var player_file : PlayerSave

signal file_selected


enum FileStatus {
	NewFile,
	SavedFile
}

func _ready() -> void:
	_set_file_to_new()

func set_file_number(number: int):
	file_number_text.text = "FILE " + str(number)
	file_index = number

func load_file_info(player_save : PlayerSave):
	name_text.text = player_save.player_name
	player_time.text = Util.float_to_time_string(player_save.player_time_spent, true)
	location_label.text = player_save.auto_save.current_location
	date_label.text = player_save.auto_save.date_saved
	player_file = player_save
	_set_file_to_saved()


func _set_file_to_new():
	file_status = FileStatus.NewFile
	new_game_text.visible = true
	file_information.visible = false
	
func _set_file_to_saved():
	file_status = FileStatus.SavedFile
	new_game_text.visible = false
	file_information.visible = true
	


func _on_button_button_up() -> void:

	file_selected.emit(self)
		
