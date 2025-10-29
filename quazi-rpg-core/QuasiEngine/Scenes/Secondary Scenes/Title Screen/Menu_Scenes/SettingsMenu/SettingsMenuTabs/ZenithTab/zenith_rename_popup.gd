extends Control


@onready var name_field = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/SettingsMenu/SettingsMenuTabs/ZenithTab/zenith_rename_popup.tscn")
@onready var name_field_stage = $UpperTitle/PanelContainer/MainStageVbox/StageMargins
@onready var field_text = $UpperTitle/PanelContainer/MainStageVbox/TextMargins/FieldText

signal accept_input
signal exit_input


func _ready() -> void:
	field_text.text = "Would you like to rename yourself? (%s Chances Left)" % GlobalData.player_save.z_renames_left
	var _name_field = name_field.instantiate()
	name_field_stage.add_child(_name_field)
	_name_field.input_selected.connect(_on_input_selected)
	_name_field.exit_input_menu.connect(_on_exit_input_menu)
	
func _on_input_selected():
	accept_input.emit()
	
func _on_exit_input_menu():
	exit_input.emit()
