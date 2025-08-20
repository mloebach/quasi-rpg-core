extends PanelContainer

signal swap_to_file_select_menu
signal start_new_file

@onready var name_text_field = $"Name Field/Control/NameField"
var slot_number: int


func load_file(player_file: int):
	slot_number = player_file

func _on_return_button_button_up() -> void:
	swap_to_file_select_menu.emit()

	

func _on_reset_button_button_up() -> void:
	name_text_field.text = ""


func _on_continue_button_button_up() -> void:
	var player_name : String = name_text_field.text.strip_edges().capitalize()
	if(player_name != ""):
		start_new_file.emit(player_name, slot_number)
