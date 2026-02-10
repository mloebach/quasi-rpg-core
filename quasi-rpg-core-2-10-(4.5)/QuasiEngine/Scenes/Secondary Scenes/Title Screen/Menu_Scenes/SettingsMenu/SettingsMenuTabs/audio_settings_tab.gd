extends Control

@onready var tts_voice_options = $MarginContainer/VBoxContainer/ButtonVBox/HBoxContainer/TextFont/MarginContainer2/TTSVoiceOptions
@onready var tts_voice_toggle = $MarginContainer/VBoxContainer/ButtonVBox/HBoxContainer/TextSize/MarginContainer2/OptionButton

@onready var volume_slider = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/SettingsMenu/volume_slider_option.tscn")
@onready var volume_slider_stage = $MarginContainer/VBoxContainer/SliderVbox

signal tts_toggled

func _ready():
	tts_voice_toggle.selected = Settings.settings_options.tts_toggle
	_create_all_audio_sliders()
	_set_tts_options()

func _set_tts_options() -> void:
	tts_voice_options.clear()
	var voice_index = 1
	for voice in Settings.tts_voices:
		tts_voice_options.add_item("Voice " + str(voice_index))
		voice_index += 1
	tts_voice_options.selected = Settings.settings_options.current_tts_voice

func _create_all_audio_sliders() -> void:
	_create_audio_slider("Main Volume", "main_volume", "Master")
	_create_audio_slider("BGM Volume", "bgm_volume", "BGM")
	_create_audio_slider("SFX Volume", "sfx_volume", "SFX")
	_create_audio_slider("Voice Volume", "voice_volume", "Voice")


func _create_audio_slider(label: String, variable: String, bus: String) -> void:
	var slider = volume_slider.instantiate()
	volume_slider_stage.add_child(slider)
	slider.initialize(label, variable, bus)


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
