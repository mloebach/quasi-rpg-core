extends Control

@onready var status_icon = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/Status_Menu/status_icon.tscn")
@onready var grid_stage = $VBoxContainer/MarginContainer/PanelContainer/MarginContainer/GridContainer

signal restore_ui

func _ready() -> void:
	_load_icons()


func _load_icons() -> void:
	print("loading status screen!")
	for character in GlobalData.custom_global_data.roster_stats:
		print("loading character: " + character)
		var new_icon = status_icon.instantiate()
		grid_stage.add_child(new_icon)
		new_icon.load_icon(GlobalData.custom_global_data.get_char_status(character))


func _on_exit_button_button_up() -> void:
	restore_ui.emit()
	queue_free()
