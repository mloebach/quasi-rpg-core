extends Control


@onready var name_field = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/File_Select/name_entry_field.tscn")
@onready var name_field_stage = $UpperTitle/PanelContainer/MainStageVbox/StageMargins
@onready var field_text = $UpperTitle/PanelContainer/MainStageVbox/TextMargins/FieldText

@onready var popup = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/choice_popup_menu.tscn")
@onready var popup_stage = $Popup_Stage

signal accept_input
signal exit_input

var input_string = ""

const swap_message = "Would you like to swap to the chosen name?"

func _ready() -> void:
	field_text.text = "Would you like to rename yourself? (Chances Left: %s)" % GlobalData.player_save.z_renames_left
	var _name_field = name_field.instantiate()
	name_field_stage.add_child(_name_field)
	_name_field.input_selected.connect(_on_input_selected)
	_name_field.exit_input_menu.connect(_on_exit_input_menu)
	_name_field.old_name = GlobalData.player_save.player_name
	_name_field.field_setup()
	

	
func _on_input_selected(input: String):
	#accept_input.emit(input)
	input_string = input
	_create_popup(_on_popup_accept, swap_message + "[br]" + GlobalData.player_save.player_name + " -> [b]" + input +"[/b]")
	
func _create_popup(confirm_function : Callable, disclaimer_string: String = "") -> void:
	var new_popup = popup.instantiate()
	popup_stage.add_child(new_popup)
	if(disclaimer_string != ""):
		new_popup.update_text(disclaimer_string)
	new_popup.pop_up_confirm.connect(confirm_function)

func _on_popup_accept():
	accept_input.emit(input_string)
	
func _on_exit_input_menu():
	exit_input.emit()
