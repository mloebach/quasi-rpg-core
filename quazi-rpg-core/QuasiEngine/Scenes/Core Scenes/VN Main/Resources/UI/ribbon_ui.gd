extends PanelContainer

signal create_settings_menu
signal create_save_menu
signal return_to_title
signal auto_toggled
signal create_status_menu

@onready var auto_button = $MarginContainer/OptionsPanel/LeftSide/AutoButton
@onready var status_button = $MarginContainer/OptionsPanel/LeftSide/StatusButton

func _ready() -> void:
	#ZenithCustomCommands.update_ui.connect(_om_update_ui)
	pass

func _on_settings_button_button_up() -> void:
	create_settings_menu.emit()
	auto_button.set_pressed(false)
	GlobalData.pause_printer()

func _on_quit_button_button_up() -> void:
	GlobalData.get_screenshot("autosave")
	#await get_tree().create_timer(0.0).timeout #this function activates too early otherwise
	return_to_title.emit()
	auto_button.set_pressed(false)
	GlobalData.pause_printer()


func _on_auto_button_toggled(toggled_on: bool) -> void:
	print("auto button pressed - %s" % toggled_on)
	auto_toggled.emit(toggled_on)
	GlobalData.auto_printer_on = toggled_on
	GlobalData.auto_timer = 0.0 #reset timer


func _on_status_button_button_up() -> void:
	create_status_menu.emit()
	GlobalData.pause_printer()
	auto_button.set_pressed(false)

func _on_update_ui(ui: String, visibile: bool):
	match ui:
		"status":
			status_button = visible
		_:
			push_warning("Unknown ui updated " + ui)


#this is going to be the current fake pause button
	


func _on_pause_debug_button_toggled(toggled_on: bool) -> void:
	GlobalData.printer_paused = toggled_on
	


func _on_save_button_button_up() -> void:
	#GlobalData.get_screenshot("autosave")
	create_save_menu.emit()
	GlobalData.pause_printer()
	auto_button.set_pressed(false)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		GlobalData.get_screenshot("autosave")
