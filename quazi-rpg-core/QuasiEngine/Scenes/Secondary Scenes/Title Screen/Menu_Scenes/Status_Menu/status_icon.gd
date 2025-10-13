extends Control

@onready var red_filter = $VBoxContainer/Icon/RedFilter
@onready var icon = $VBoxContainer/Icon
@onready var name_text = $VBoxContainer/Name
@onready var role_text = $VBoxContainer/Role
@onready var link_lost_filter = $VBoxContainer/Icon/BlueFilter
@onready var locked_filter = $VBoxContainer/Icon/LockedFilter

func load_icon(char: String, status : Zenith_Global_Data.CharacterStatus):
	icon.texture = GlobalData.get_default_icon(char)
	name_text.text = "[b]" + GlobalData.get_char_fullname(char) + "[/b]" 
	
	match status:
		Zenith_Global_Data.CharacterStatus.Eliminated:
			link_lost_filter.visible = true
			locked_filter.visible = false
			name_text.modulate = Color.CRIMSON
			role_text.modulate = Color.CRIMSON
			role_text.visible = true
			name_text.visible = true
		Zenith_Global_Data.CharacterStatus.Locked:
			locked_filter.visible = true
			link_lost_filter.visible = false
			role_text.visible = false
			name_text.visible = false
		Zenith_Global_Data.CharacterStatus.Active:
			link_lost_filter.visible = false
			locked_filter.visible = false
			name_text.modulate = Color.WHITE
			role_text.modulate = Color.WHITE
			role_text.visible = true
			name_text.visible = true
	#if char.status == Zenith_Global_Data.CharacterStatus.Eliminated:
		
	
		
	if GlobalData.characters[char].custom_variables.has("Role"):
		role_text.text = "[i]" + GlobalData.characters[char].custom_variables["Role"] + "[/i]"
		#role_text.visible = true
		

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("clicked on icon!")
