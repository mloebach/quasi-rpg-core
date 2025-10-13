extends HBoxContainer

#@export var sample_audio : AudioStream

@onready var value_label = $MarginContainer3/ValueLabel
@onready var slider = $MarginContainer2/HSlider
@onready var audio_player = $AudioStreamPlayer
@onready var test_button = $PlayTest

@onready var volume_label = $MarginContainer/VolumeLabel
var volume_variable : String
var volume_bus : String

#var name_string = ""
#var 

func _ready() -> void:
	pass

func initialize(value: String, variable: String, bus: String) -> void:
	volume_label.text = value
	volume_variable = variable
	volume_bus = bus
	slider.value = Settings.settings_options[volume_variable]
	audio_player.bus = bus

#func setup_slider(name_string : String) -> void:
	#volume_label.text = name_string

#func _on_h_slider_drag_ended(value_changed: bool) -> void:
	#value_label.text = str(int(slider.value))


#func _on_h_slider_drag_started() -> void:
	#value_label.text = str(int(slider.value))


func _on_h_slider_value_changed(value: float) -> void:
	value_label.text = str(int(slider.value))
	Settings.settings_options[volume_variable] = value
	var index = AudioServer.get_bus_index(volume_bus)
	var volumedb : float = linear_to_db(value/100.0)
	AudioServer.set_bus_volume_db(index, volumedb)
	
	


func _on_play_test_button_up() -> void:
	if audio_player.playing:
		audio_player.stop()
		test_button.text = "Play"
	else:
		audio_player.play()
		test_button.text = "Stop"


func _on_h_slider_drag_ended(value_changed: bool) -> void:
	#save to options
	Settings.save_settings()
	pass # Replace with function body.
