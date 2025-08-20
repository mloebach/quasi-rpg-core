extends HBoxContainer

@onready var value_label = $MarginContainer3/ValueLabel
@onready var slider = $MarginContainer2/HSlider

@onready var volume_label = $MarginContainer/VolumeLabel

#var name_string = ""
#var 


#func _ready() -> void:
	#pass
	#
func setup_slider(name_string : String) -> void:
	volume_label.text = name_string

func _on_h_slider_drag_ended(value_changed: bool) -> void:
	value_label.text = str(int(slider.value))
