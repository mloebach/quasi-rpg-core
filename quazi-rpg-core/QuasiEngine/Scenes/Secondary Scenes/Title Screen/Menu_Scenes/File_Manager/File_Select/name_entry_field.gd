extends PanelContainer

@onready var name_text_field = $VBoxContainer/Control/NameField
@onready var continue_button = $VBoxContainer/BottomButtons/HBoxContainer/ContinueButton

var old_name = ""
var current_text = ""

#signal swap_to_file_select_menu
#signal start_new_file

signal input_selected
signal exit_input_menu

func field_setup():
	name_text_field.text = old_name
	current_text = old_name
	continue_button.disabled = true
	

func _on_return_button_button_up() -> void:
	exit_input_menu.emit()
	#self.queue_free()

	

func _on_reset_button_button_up() -> void:
	#name_text_field.text = old_name
	#current_text = old_name
	#continue_button.disabled = true
	field_setup()

func _on_continue_button_button_up() -> void:
	#var player_name : String = name_text_field.text.strip_edges()
	#if(player_name != ""):
		#start_new_file.emit(player_name, slot_number)
	input_selected.emit(name_text_field.text)
	#self.queue_free()


func _on_name_field_text_changed(new_text: String) -> void:
	#name_text_field.editable = false
	#name_text_field.text = ""
	var caret : int = name_text_field.caret_column
	
	print("Character: "+ new_text)
	
	
	if current_text.length() < new_text.length(): #more characters
		#name_text_field.text = new_text.capitalize()
		#convert to lower
		#var new_index = Util.new_char_int(new_text, current_text)
		#var new_index = caret-1
		var diff = new_text.length() - current_text.length()
		for index in range(caret-diff, caret):
			if !Util.is_valid_name_char(new_text[index]):
				name_text_field.text = current_text
				name_text_field.caret_column = index
				return
			
			if Util.is_char_lower(new_text[index]):
				print("lowercase character spotted:" + new_text[index])
				new_text[index] = char(new_text.unicode_at(index)-32)
			#if !Util.is_valid_name_char(new_text[new_index]):
				#name_text_field.text = current_text
				#name_text_field.caret_column = new_index
				#return
			#
			#if Util.is_char_lower(new_text[new_index]):
				#print("lowercase character spotted:" + new_text[new_index])
				#new_text[new_index] = char(new_text.unicode_at(new_index)-32)
#		name_text_field.caret_column = new_text.length()
		#carat+=1
		#name_text_field.caret_column +=1
	else:
		pass
	name_text_field.text = new_text
	name_text_field.caret_column = caret
	current_text = new_text
	#name_text_field.editable = true

	if new_text == old_name || new_text == "":
		continue_button.disabled = true
	else:
		continue_button.disabled = false
