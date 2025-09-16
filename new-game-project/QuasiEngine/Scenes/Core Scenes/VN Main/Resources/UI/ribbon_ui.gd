extends PanelContainer

signal create_settings_menu
signal return_to_title
signal auto_toggled
signal create_status_menu

@onready var auto_button = $MarginContainer/OptionsPanel/LeftSide/AutoButton

func _on_settings_button_button_up() -> void:
	create_settings_menu.emit()
	auto_button.set_pressed(false)
	GlobalData.pause_printer()

func _on_quit_button_button_up() -> void:
	return_to_title.emit()
	auto_button.set_pressed(false)
	GlobalData.pause_printer()


func _on_auto_button_toggled(toggled_on: bool) -> void:
	#auto_toggled.emit()
	GlobalData.auto_printer_on = toggled_on
	GlobalData.auto_timer = 0.0 #reset timer


func _on_status_button_button_up() -> void:
	create_status_menu.emit()
	GlobalData.pause_printer()
	auto_button.set_pressed(false)



#this is going to be the current fake pause button
	


func _on_pause_debug_button_toggled(toggled_on: bool) -> void:
	GlobalData.printer_paused = toggled_on
	
