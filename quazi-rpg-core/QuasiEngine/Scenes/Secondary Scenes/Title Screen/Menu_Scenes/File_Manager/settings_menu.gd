extends Control

#@onready var resolution_toggle = $VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MainSettings/PanelContainer/SettingTabs/Graphics/Graphics/VBoxContainer/SliderVbox/Resolution/MarginContainer3/OptionButton
#@onready var fullscreen_toggle = $VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MainSettings/PanelContainer/SettingTabs/Graphics/Graphics/VBoxContainer/SliderVbox/Fullscreen/MarginContainer3/FullScreen
#@onready var resizable_toggle = $VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MainSettings/PanelContainer/SettingTabs/Graphics/Graphics/VBoxContainer/SliderVbox/Resizable/MarginContainer3/ResizeToggle

#@export var default_res_option := 2

#@onready var tts_voice_options = $VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MainSettings/PanelContainer/SettingTabs/Audio/MarginContainer/VBoxContainer/ButtonVBox/HBoxContainer/TextFont/MarginContainer2/TTSVoiceOptions
#@onready var tts_voice_toggle = $VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MainSettings/PanelContainer/SettingTabs/Audio/MarginContainer/VBoxContainer/ButtonVBox/HBoxContainer/TextSize/MarginContainer2/OptionButton

#@onready var volume_slider = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/SettingsMenu/volume_slider_option.tscn")
#@onready var volume_slider_stage = $VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MainSettings/PanelContainer/SettingTabs/Audio/MarginContainer/VBoxContainer/SliderVbox


@onready var tab_stage = $VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MainSettings/PanelContainer/SettingTabs
@onready var zenith_tab = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/SettingsMenu/SettingsMenuTabs/zenith_tab.tscn")
@onready var controls_tab = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/SettingsMenu/SettingsMenuTabs/control_tab.tscn")
@onready var text_tab = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/SettingsMenu/SettingsMenuTabs/text_tab.tscn")
@onready var audio_tab = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/SettingsMenu/SettingsMenuTabs/audio_tab.tscn")
@onready var graphics_tab = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/SettingsMenu/SettingsMenuTabs/graphics_tab.tscn")

@onready var name_entry_field = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/SettingsMenu/SettingsMenuTabs/ZenithTab/zenith_rename_popup.tscn")

@onready var popup_stage = $"Popup Stage"
@onready var block_panel = $"BlockPanel"

var active_tabs : Dictionary[String, Control] = {}
var tab_names : Array[String] = []
var current_tab : String = ""

signal tts_toggled
signal restore_ui
signal update_z_tab
#var resolutions : Dictionary[String,Vector2] = {
	#"1920x1080" = Vector2(1920,1080),
	#"1280x720" = Vector2(1920,1080),
#}

#@export var resolution_array : Array[String]

func _ready() -> void:
#	_load_values()
	#resolution_toggle.selected = Settings.settings_options.current_window_size_index
	#fullscreen_toggle.selected = Settings.settings_options.current_window_mode_index
	#resizable_toggle.selected = Settings.settings_options.current_resizable_window_toggle
	#tts_voice_toggle.selected = Settings.settings_options.tts_toggle
	
	#_create_all_audio_sliders()
	#_set_resolution_values()
	#_set_tts_options()
	load_settings_tabs()
	if !tab_names.has(Settings.settings_options.last_opened_tab): #default to first tab if you cant find tab type
	#Settings.settings_options.last_opened_tab == "":
		active_tabs[tab_names[0]].show()
	else:
		active_tabs[Settings.settings_options.last_opened_tab].show()
	
	#_update_window_size(GlobalData.current_window_size_index)

func load_settings_tabs():
	load_tab(graphics_tab, "Graphics")
	load_tab(audio_tab, "Audio")
	active_tabs["Audio"].tts_toggled.connect(_on_tts_toggled)
	load_tab(text_tab, "Text")
	load_tab(controls_tab, "Controls")
	load_z_tab()
	#if GlobalData.current_scene_status == GlobalData.SceneTypes.in_game:
		#var z_tab = load_tab(zenith_tab, "[" + GlobalData.player_save.player_name.capitalize() + "]")
		#z_tab.create_name_field.connect(_on_create_name_field)
		#update_z_tab.connect(z_tab._on_update_z_tab)
	#active_tabs["Graphics"].show()

func load_z_tab():
	if GlobalData.current_scene_status == GlobalData.SceneTypes.in_game:
		var z_tab = load_tab(zenith_tab, "[" + GlobalData.player_save.player_name + "]")
		z_tab.create_name_field.connect(_on_create_name_field)
		update_z_tab.connect(z_tab._on_update_z_tab)

func load_tab(tab_object, tab_name: String):
	var new_tab = tab_object.instantiate()
	tab_stage.add_child(new_tab)
	new_tab.name = tab_name
	tab_names.append(tab_name)
	active_tabs[tab_name] = new_tab
	return new_tab

func _on_tts_toggled(index: int):
	tts_toggled.emit(index)

func _on_yes_button_button_up() -> void:
	#_save_settings()
	exit_settings_menu()
	

func _on_no_button_button_up() -> void:
	exit_settings_menu()

func exit_settings_menu() -> void:
	Settings.settings_options.last_opened_tab = tab_names[tab_stage.current_tab]
	Settings.save_settings()
	restore_ui.emit()
	queue_free()

#func _on_setting_tabs_tab_changed(tab: int) -> void:
	#current_tab = tab_names[tab]
	
	
func _on_setting_tabs_tab_clicked(tab: int) -> void:
	current_tab = tab_names[tab]

func _on_create_name_field() -> void:
	block_panel.show()
	var _name_entry_field = name_entry_field.instantiate()
	popup_stage.add_child(_name_entry_field)
	_name_entry_field.accept_input.connect(_on_accept_name_field)
	_name_entry_field.exit_input.connect(_on_exit_name_field)
	
func _on_exit_name_field() -> void:
	block_panel.hide()
	for child in popup_stage.get_children():
		child.queue_free()
		
func _on_accept_name_field(input: String) -> void:
	print(input)
	active_tabs["[" + GlobalData.player_save.player_name + "]"].queue_free()
	active_tabs.erase("[" + GlobalData.player_save.player_name + "]")
	#change zenith name
	GlobalData.player_save.z_renames_left -= 1
	GlobalData.player_save.player_name = input
	GlobalData.ingame_variables["zenith_name"] = "[" + input + "]"
	#update_z_tab.emit()
	GlobalData.create_autosave()
	GlobalData.save_player_file()
	load_z_tab()
	active_tabs["[" + GlobalData.player_save.player_name + "]"].show()
	
	_on_exit_name_field()

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




#func load_player_tab():
	#if GlobalData.current_scene_status == GlobalData.SceneTypes.in_game:
		#var player_tab = zenith_tab.instantiate()
		#tab_stage.add_child(player_tab)
		#player_tab.name = "[" + GlobalData.player_save.player_name.capitalize() + "]"

#func _create_all_audio_sliders() -> void:
	#_create_audio_slider("Main Volume", "main_volume", "Master")
	#_create_audio_slider("BGM Volume", "bgm_volume", "BGM")
	#_create_audio_slider("SFX Volume", "sfx_volume", "SFX")
	#_create_audio_slider("Voice Volume", "voice_volume", "Voice")
	

	
#func _create_audio_slider(label: String, variable: String, bus: String) -> void:
	#var slider = volume_slider.instantiate()
	#volume_slider_stage.add_child(slider)
	#slider.initialize(label, variable, bus)

#func _set_resolution_values() -> void:
	#resolution_toggle.clear()
	#for item in Settings.display_resolutions:
		##resolutionArray.append(item)
		#resolution_toggle.add_item(item)
	#resolution_toggle.selected = Settings.settings_options.current_window_size_index

#func _set_tts_options() -> void:
	#tts_voice_options.clear()
	#var voice_index = 1
	#for voice in Settings.tts_voices:
		#tts_voice_options.add_item("Voice " + str(voice_index))
		#voice_index += 1
	#tts_voice_options.selected = Settings.settings_options.current_tts_voice




#func _save_settings() -> void:
	#pass
	#exit_settings_menu()

#func _adjust_window_mode() -> void:
	
#func _resolution_string_to_vector(res : String) -> Vector2:
	#
	#var split_string = res.split("x", false, 1)
	#var dimensions := Vector2(
		#int(split_string[0].strip_edges()), int(split_string[1].strip_edges())
	#)
	#
	#return dimensions

#func _on_window_mode_item_selected(index: int) -> void:
	#Settings.window_mode_select(index)
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

#func _on_resize_toggle_item_selected(index: int) -> void:
	#Settings.resize_toggle(index)
	##Settings.settings_options.current_resizable_window_toggle = index
	##match index:
		##0: 
			##DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)
		##1:
			##DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, false)
	##Settings.save_settings()
#
#func _on_dimension_option_button_item_selected(index: int) -> void:
	##get_viewport().size = _resolution_string_to_vector(resolution_array[index])
	#Settings.update_window_size(index)
	#
	
#func _update_window_size(index: int):
	##GlobalData.current_window_size_index = index
	#Settings.settings_options.current_window_size_index = index
	#if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		#get_viewport().size = _resolution_string_to_vector(Settings.display_resolutions[index])
	#Settings.save_settings()
		




#func _on_option_button_item_selected(index: int) -> void:
	#print("TTS Voice toggled.")
	#match index:
		#0:
			#Settings.settings_options.tts_toggle = false
			#DisplayServer.tts_stop()
		#1:
			#Settings.settings_options.tts_toggle = true
			#GlobalData.tts_speak("Text to speech on.")
		#_:
			#push_warning("Unknown option selected.")
	#tts_toggled.emit(index)
	#Settings.save_settings()
#
#
#func _on_tts_voice_options_item_selected(index: int) -> void:
	#Settings.settings_options.current_tts_voice = index
	#GlobalData.tts_speak("Switched to Voice " + str(index+1))
	#Settings.save_settings()
