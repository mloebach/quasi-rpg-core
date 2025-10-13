extends Control

@onready var resolution_toggle = $VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MainSettings/PanelContainer/SettingTabs/Graphics/Graphics/VBoxContainer/SliderVbox/Resolution/MarginContainer3/OptionButton
@onready var fullscreen_toggle = $VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MainSettings/PanelContainer/SettingTabs/Graphics/Graphics/VBoxContainer/SliderVbox/Fullscreen/MarginContainer3/FullScreen
@onready var resizable_toggle = $VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MainSettings/PanelContainer/SettingTabs/Graphics/Graphics/VBoxContainer/SliderVbox/Resizable/MarginContainer3/ResizeToggle
#@export var default_res_option := 2

@onready var tts_voice_options = $VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MainSettings/PanelContainer/SettingTabs/Audio/MarginContainer/VBoxContainer/ButtonVBox/HBoxContainer/TextFont/MarginContainer2/TTSVoiceOptions
@onready var tts_voice_toggle = $VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MainSettings/PanelContainer/SettingTabs/Audio/MarginContainer/VBoxContainer/ButtonVBox/HBoxContainer/TextSize/MarginContainer2/OptionButton

@onready var volume_slider = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/SettingsMenu/volume_slider_option.tscn")
@onready var volume_slider_stage = $VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MainSettings/PanelContainer/SettingTabs/Audio/MarginContainer/VBoxContainer/SliderVbox

signal tts_toggled
signal restore_ui
#var resolutions : Dictionary[String,Vector2] = {
	#"1920x1080" = Vector2(1920,1080),
	#"1280x720" = Vector2(1920,1080),
#}

#@export var resolution_array : Array[String]

func _ready() -> void:
#	_load_values()
	resolution_toggle.selected = Settings.settings_options.current_window_size_index
	fullscreen_toggle.selected = Settings.settings_options.current_window_mode_index
	resizable_toggle.selected = Settings.settings_options.current_resizable_window_toggle
	tts_voice_toggle.selected = Settings.settings_options.tts_toggle
	
	_create_all_audio_sliders()
	_set_resolution_values()
	_set_tts_options()
	#_update_window_size(GlobalData.current_window_size_index)

#func _load_values():
	#if not FileAccess.file_exists(GlobalData.global_save_path):
		#return
	#var global_save = FileAccess.open(GlobalData.global_save_path, FileAccess.READ)
	#global_save.get_line() #skip first line
	#var settings_json = global_save.get_line()
	#var json = JSON.new()
	#var parse_result = json.parse(settings_json)
	#if not parse_result == OK:
		#print("JSON Parse Error: ", json.get_error_message(), " in ", settings_json, " at line ", json.get_error_line())
		#return
	#var node_data = json.data
	#for i in node_data.keys():
		#

func _create_all_audio_sliders() -> void:
	_create_audio_slider("Main Volume", "main_volume", "Master")
	_create_audio_slider("BGM Volume", "bgm_volume", "BGM")
	_create_audio_slider("SFX Volume", "sfx_volume", "SFX")
	_create_audio_slider("Voice Volume", "voice_volume", "Voice")
	

	
func _create_audio_slider(label: String, variable: String, bus: String) -> void:
	var slider = volume_slider.instantiate()
	volume_slider_stage.add_child(slider)
	slider.initialize(label, variable, bus)

func _set_resolution_values() -> void:
	resolution_toggle.clear()
	for item in Settings.display_resolutions:
		#resolutionArray.append(item)
		resolution_toggle.add_item(item)
	resolution_toggle.selected = Settings.settings_options.current_window_size_index

func _set_tts_options() -> void:
	tts_voice_options.clear()
	var voice_index = 1
	for voice in Settings.tts_voices:
		tts_voice_options.add_item("Voice " + str(voice_index))
		voice_index += 1
	tts_voice_options.selected = Settings.settings_options.current_tts_voice

func _on_yes_button_button_up() -> void:
	#_save_settings()
	exit_settings_menu()
	
#func _save_settings() -> void:
	#pass
	#exit_settings_menu()


func _on_no_button_button_up() -> void:
	exit_settings_menu()

func exit_settings_menu() -> void:
	restore_ui.emit()
	queue_free()

#func _adjust_window_mode() -> void:
	
#func _resolution_string_to_vector(res : String) -> Vector2:
	#
	#var split_string = res.split("x", false, 1)
	#var dimensions := Vector2(
		#int(split_string[0].strip_edges()), int(split_string[1].strip_edges())
	#)
	#
	#return dimensions

func _on_window_mode_item_selected(index: int) -> void:
	Settings.window_mode_select(index)
	#windowed = 0, fullscreen = 1, borderless = 2
	#Settings.settings_options.current_window_mode_index = index
	#match index:
		#0:
			##DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			##DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			##_update_window_size(GlobalData.current_window_size_index)
			#_set_windowed_mode()
		#1:
			#_set_fullscreen_mode()
		#2:
			#_set_borderless_fullscreen_mode()
		#_:
			#push_error("Window mode not found!")
	#Settings.save_settings()
#
#func _set_windowed_mode():
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	#_update_window_size(Settings.settings_options.current_window_size_index)
#
#func _set_fullscreen_mode():
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
#
#func _set_borderless_fullscreen_mode():
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

func _on_resize_toggle_item_selected(index: int) -> void:
	Settings.resize_toggle(index)
	#Settings.settings_options.current_resizable_window_toggle = index
	#match index:
		#0: 
			#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)
		#1:
			#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, false)
	#Settings.save_settings()

func _on_dimension_option_button_item_selected(index: int) -> void:
	#get_viewport().size = _resolution_string_to_vector(resolution_array[index])
	Settings.update_window_size(index)
	
	
#func _update_window_size(index: int):
	##GlobalData.current_window_size_index = index
	#Settings.settings_options.current_window_size_index = index
	#if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		#get_viewport().size = _resolution_string_to_vector(Settings.display_resolutions[index])
	#Settings.save_settings()
		




func _on_option_button_item_selected(index: int) -> void:
	print("TTS Voice toggled.")
	match index:
		0:
			Settings.settings_options.tts_toggle = false
			DisplayServer.tts_stop()
		1:
			Settings.settings_options.tts_toggle = true
			GlobalData.tts_speak("Text to speech on.")
		_:
			push_warning("Unknown option selected.")
	tts_toggled.emit(index)
	Settings.save_settings()


func _on_tts_voice_options_item_selected(index: int) -> void:
	Settings.settings_options.current_tts_voice = index
	GlobalData.tts_speak("Switched to Voice " + str(index+1))
	Settings.save_settings()
