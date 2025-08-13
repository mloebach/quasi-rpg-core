extends PanelContainer

signal swap_to_file_select_menu

@onready var name_text_field = $"Name Field/Control/NameField"


func _on_return_button_button_up() -> void:
	swap_to_file_select_menu.emit()

	

func _on_reset_button_button_up() -> void:
	name_text_field.text = ""
