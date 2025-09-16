extends Control

@onready var resolution_toggle = $VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MainSettings/PanelContainer/SettingTabs/Graphics/Graphics/VBoxContainer/SliderVbox/Resolution/MarginContainer3/OptionButton
@export var default_res_option := 2

@onready var tts_voice_options = $VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MainSettings/PanelContainer/SettingTabs/Audio/MarginContainer/VBoxContainer/ButtonVBox/HBoxContainer/TextFont/MarginContainer2/TTSVoiceOptions
@onready var tts_voice_toggle = $VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MainSettings/PanelContainer/SettingTabs/Audio/MarginContainer/VBoxContainer/ButtonVBox/HBoxContainer/TextSize/MarginContainer2/OptionButton

signal tts_toggled
signal restore_ui
#var resolutions : Dictionary[String,Vector2] = {
	#"1920x1080" = Vector2(1920,1080),
	#"1280x720" = Vector2(1920,1080),
#}

#@export var resolution_array : Array[String]

func _ready() -> void:
	_set_resolution_values()
	_set_tts_options()
	#_update_window_size(GlobalData.current_window_size_index)

func _set_resolution_values() -> void:
	resolution_toggle.clear()
	for item in Settings.display_resolutions:
		#resolutionArray.append(item)
		resolution_toggle.add_item(item)
	resolution_toggle.selected = default_res_option

func _set_tts_options() -> void:
	tts_voice_options.clear()
	var voice_index = 1
	for voice in Settings.tts_voices:
		tts_voice_options.add_item("Voice " + str(voice_index))
		voice_index += 1
	tts_voice_options.selected = Settings.current_tts_voice

func _on_yes_button_button_up() -> void:
	_save_settings()
	
func _save_settings() -> void:
	pass
	exit_settings_menu()


func _on_no_button_button_up() -> void:
	exit_settings_menu()

func exit_settings_menu() -> void:
	restore_ui.emit()
	queue_free()

#func _adjust_window_mode() -> void:
	
func _resolution_string_to_vector(res : String) -> Vector2:
	
	var split_string = res.split("x", false, 1)
	var dimensions := Vector2(
		int(split_string[0].strip_edges()), int(split_string[1].strip_edges())
	)
	
	return dimensions

func _on_window_mode_item_selected(index: int) -> void:
	#windowed = 0, fullscreen = 1, borderless = 2
	Settings.current_window_mode_index = index
	match index:
		0:
			#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			#_update_window_size(GlobalData.current_window_size_index)
			_set_windowed_mode()
		1:
			_set_fullscreen_mode()
		2:
			_set_borderless_fullscreen_mode()
		_:
			push_error("Window mode not found!")


func _set_windowed_mode():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	_update_window_size(GlobalData.current_window_size_index)

func _set_fullscreen_mode():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _set_borderless_fullscreen_mode():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

func _on_resize_toggle_item_selected(index: int) -> void:
	Settings.current_resizable_window_toggle = index
	match index:
		0: 
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)
		1:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, false)


func _on_dimension_option_button_item_selected(index: int) -> void:
	#get_viewport().size = _resolution_string_to_vector(resolution_array[index])
	_update_window_size(index)
	
func _update_window_size(index: int):
	#GlobalData.current_window_size_index = index
	Settings.current_window_size_index = index
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		get_viewport().size = _resolution_string_to_vector(Settings.display_resolutions[index])
	
		




func _on_option_button_item_selected(index: int) -> void:
	print("TTS Voice toggled.")
	match index:
		0:
			Settings.tts_toggle = false
			DisplayServer.tts_stop()
		1:
			Settings.tts_toggle = true
			GlobalData.tts_speak("Text to speech on.")
		_:
			push_warning("Unknown option selected.")
	tts_toggled.emit(index)


func _on_tts_voice_options_item_selected(index: int) -> void:
	Settings.current_tts_voice = index
	GlobalData.tts_speak("Switched to Voice " + str(index+1))
