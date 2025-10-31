extends Control

signal swap_to_file_select_menu
signal start_new_file

#@onready var name_text_field = $"Name Field/Control/NameField"
@onready var name_entry_field = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/File_Select/name_entry_field.tscn")
@onready var entry_stage = $"."

#var current_text = ""
var slot_number: int


func load_file(player_file: int):
	slot_number = player_file

func _ready():
	var entry_field = name_entry_field.instantiate()
	entry_field.input_selected.connect(_on_input_selected)
	entry_field.exit_input_menu.connect(_on_exit_input_menu)
	entry_stage.add_child(entry_field)
	entry_field.field_setup()

func _on_exit_input_menu() -> void:
	swap_to_file_select_menu.emit()
#

#
#func _on_reset_button_button_up() -> void:
	#name_text_field.text = ""
#
#

func _on_input_selected(field_text: String) -> void:
	var player_name : String = field_text.strip_edges()
	if(player_name != ""):
		start_new_file.emit(player_name, slot_number)

#func _on_continue_button_button_up() -> void:
	#var player_name : String = name_text_field.text.strip_edges()
	#if(player_name != ""):
		#start_new_file.emit(player_name, slot_number)
#
#
#func _on_name_field_text_changed(new_text: String) -> void:
	#var caret : int = name_text_field.caret_column
	#if current_text.length() < new_text.length(): #more characters
		##name_text_field.text = new_text.capitalize()
		##convert to lower
		#var new_index = Util.new_char_int(new_text, current_text)
		#
		#if !Util.is_valid_name_char(new_text[new_index]):
			#name_text_field.text = current_text
			#name_text_field.caret_column = caret-1
			#return
		#
		#if Util.is_char_lower(new_text[new_index]):
			#print("lowercase character spotted")
			#new_text[new_index] = char(new_text.unicode_at(new_index)-32)
##		name_text_field.caret_column = new_text.length()
		##carat+=1
	#else:
		#pass
	#name_text_field.text = new_text
	#name_text_field.caret_column = caret
	#current_text = new_text
