extends Control


@onready var disclaimer_text = $VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MarginContainer/DisclaimerText

var disclaimer_string : String = "???"

signal pop_up_confirm

func _ready() -> void:
	update_text(disclaimer_string)

func update_text(text: String):
	disclaimer_text.text = text

func _on_no_button_button_up() -> void:
	queue_free()

func _on_yes_button_button_up() -> void:
	pop_up_confirm.emit()
