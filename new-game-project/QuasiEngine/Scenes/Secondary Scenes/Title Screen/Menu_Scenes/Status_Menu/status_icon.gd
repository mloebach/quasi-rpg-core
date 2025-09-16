extends Control

@onready var red_filter = $VBoxContainer/Icon/RedFilter
@onready var icon = $VBoxContainer/Icon
@onready var name_text = $VBoxContainer/Name
@onready var role_text = $VBoxContainer/Role
@onready var link_lost_filter = $VBoxContainer/Icon/BlueFilter

func load_icon(char : Zenith_Global_Data.StatusChar):
	icon.texture = char.icon
	name_text.text = "[b]" + GlobalData.get_char_fullname(char.name) + "[/b]" 
	if char.status == Zenith_Global_Data.CharacterStatus.Eliminated:
		link_lost_filter.visible = true
		name_text.modulate = Color.CRIMSON
		role_text.modulate = Color.CRIMSON
	else:
		name_text.modulate = Color.WHITE
		role_text.modulate = Color.WHITE
	if GlobalData.characters[char.name].custom_variables.has("Role"):
		role_text.text = "[i]" + GlobalData.characters[char.name].custom_variables["Role"] + "[/i]"
		role_text.visible = true
		

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("clicked on icon!")
