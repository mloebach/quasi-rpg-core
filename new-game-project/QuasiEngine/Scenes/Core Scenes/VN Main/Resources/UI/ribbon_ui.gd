extends PanelContainer

signal create_settings_menu
signal return_to_title
signal auto_toggled

@onready var auto_button = $MarginContainer/OptionsPanel/LeftSide/AutoButton

func _on_settings_button_button_up() -> void:
	create_settings_menu.emit()
	auto_button.set_pressed(false)


func _on_quit_button_button_up() -> void:
	return_to_title.emit()
	auto_button.set_pressed(false)


func _on_auto_button_toggled(toggled_on: bool) -> void:
	#auto_toggled.emit()
	GlobalData.auto_printer_on = toggled_on
	GlobalData.auto_timer = 0.0 #reset timer
