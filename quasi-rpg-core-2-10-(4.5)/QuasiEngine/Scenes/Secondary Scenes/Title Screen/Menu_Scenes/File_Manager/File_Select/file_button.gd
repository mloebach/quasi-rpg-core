extends HBoxContainer
class_name PlayerFileButton

@onready var new_game_text = $File/HBoxContainer/Button/MarginContainer/NewGameText
@onready var file_information = $File/HBoxContainer/Button/MarginContainer/FileInfo

@onready var name_text = $File/HBoxContainer/Button/MarginContainer/FileInfo/HBoxContainer/Name
@onready var player_time = $"File/HBoxContainer/Button/MarginContainer/FileInfo/HBoxContainer/Time Label"
@onready var location_label = $"File/HBoxContainer/Button/MarginContainer/FileInfo/HBoxContainer2/Quest Label"
@onready var date_label = $File/HBoxContainer/Button/MarginContainer/FileInfo/HBoxContainer2/DateText
@onready var file_number_text = $File/HBoxContainer/PanelContainer/FileNumber

@onready var button = $File/HBoxContainer/Button

@onready var erase_filter = $File/EraseMode
var erase_filter_color = Color(Color.WHITE, 0.6)
var erase_filter_hover_color = Color(Color.CRIMSON, 0.6)
@onready var erase_selected_filter = $File/EraseSelected

@onready var lock_filter = $File/LockMode
@onready var copy_filter = $File/CopyMode

var mode : FileSelect.FileSelectMode = FileSelect.FileSelectMode.Normal

var file_index: int
var file_status : FileStatus
var player_file : PlayerSave = PlayerSave.new()

signal file_selected
signal which_slot_to_copy
signal erase_selected_file
signal option_confirmed
signal copy_to_slot

enum FileStatus {
	NewFile,
	SavedFile
}

func _ready() -> void:
	erase_filter.hide()
	lock_filter.hide()
	copy_filter.hide()
	erase_filter.modulate = erase_filter_color
	_set_file_to_new()

func set_file_number(number: int):
	file_number_text.text = "FILE " + str(number)
	file_index = number

func load_file_info(player_save : PlayerSave):
	name_text.text = player_save.player_name
	player_time.text = Util.float_to_time_string(player_save.player_time_spent, true)
	var json = FileAccess.open(player_save.auto_save_json, FileAccess.READ)
	var auto : GameSave = player_save.load_game_save(json)
	location_label.text = auto.current_location
	date_label.text = auto.date_saved
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
	if mode == FileSelect.FileSelectMode.Normal:
		file_selected.emit(self)
	elif mode == FileSelect.FileSelectMode.CopyWhichFile:
		copy_filter.show()
		button.disabled = true
		which_slot_to_copy.emit(file_index)
	elif mode == FileSelect.FileSelectMode.Erase:
		erase_selected_file.emit(file_index)
		#option_confirmed.emit()
	elif mode == FileSelect.FileSelectMode.CopyToSlot:
		copy_to_slot.emit(file_index)
		
func _on_erase_mode_on():
	mode = FileSelect.FileSelectMode.Erase
	if file_status == FileStatus.NewFile:
		button.disabled = true
		lock_filter.show()
	else:
		erase_filter.visible = true
	
func _on_copy_mode_on():
	mode = FileSelect.FileSelectMode.CopyWhichFile
	if file_status == FileStatus.NewFile:
		button.disabled = true
		lock_filter.show()
	
func _on_which_to_copy(index: int):
	mode = FileSelect.FileSelectMode.CopyToSlot
	if file_index != index:
		if file_status == FileStatus.NewFile:
			button.disabled = false
			lock_filter.hide()
		elif file_status == FileStatus.SavedFile:
			button.disabled = true
			lock_filter.show()
	
func _on_exit_to_normal():
	mode = FileSelect.FileSelectMode.Normal
	erase_filter.visible = false
	erase_selected_filter.visible = false
	button.disabled = false
	lock_filter.hide()
	copy_filter.hide()

#func _on_erase_mode_mouse_entered() -> void:
	#erase_filter.modulate = erase_filter_hover_color
	#

#
#
#func _on_erase_mode_mouse_exited() -> void:
	#erase_filter.modulate = erase_filter_color
#

func _on_button_mouse_entered() -> void:
	erase_filter.modulate = erase_filter_hover_color


func _on_button_mouse_exited() -> void:
	erase_filter.modulate = erase_filter_color
