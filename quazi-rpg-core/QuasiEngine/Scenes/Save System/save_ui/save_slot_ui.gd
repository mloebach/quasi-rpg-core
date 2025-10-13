extends VBoxContainer
class_name SaveSlotUI

@onready var save_image = $AutoSave
@onready var save_label = $AutosaveLabel
@onready var hover_texture = $AutoSave/HoverTexture
@onready var clicked_texture = $AutoSave/ClickedTexture



var clicked := false
var save_info : SaveInfo = SaveInfo.new()


signal mouse_hover
signal mouse_exit
signal slot_selected
signal slot_unselected

#var empty = true

func load_image_from_path(image: String):
	#var file = FileAccess.open(GlobalData.current_file_path() + "/Screenshots/" + image + ".webp", FileAccess.READ)
	var file = GlobalData.current_file_path() + "/Screenshots/" + image + ".webp"
	#var file = "user://" + image + ".webp"
	#if !save_image.load(file):
		#push_error("No image at " + file)
		#return
	var webp = Image.load_from_file(file)
	#var webp = load(file)
	if webp != null:
		save_image.texture = ImageTexture.create_from_image(webp)
	#save_image.texture = webp
func load_save_path(slot: String, path : String):
	save_info.slot_string = slot
	save_label.text = slot
	save_info.save_path = path
	
	var json = FileAccess.open(path, FileAccess.READ)
	if json == null:
		return
	var player_save = PlayerSave.new()
	var auto = player_save.load_game_save(json)
	save_info.date_info = auto.date_saved
	save_info.episode_info = auto.current_quest
	save_info.location_info = auto.current_location
	save_info.empty = false
	

func _on_auto_save_mouse_entered() -> void:
	if !clicked:
		hover_texture.show()
		mouse_hover.emit(save_info)


func _on_auto_save_mouse_exited() -> void:
	if !clicked:
		hover_texture.hide()
		mouse_exit.emit()


func _on_unselect():
	unselect()


func select():
	clicked = true
	clicked_texture.visible = true

func unselect():
	clicked = false
	clicked_texture.visible = false
	hover_texture.hide()

func _on_auto_save_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			flip_icon()
			#print("clicked on icon!")

func flip_icon():
	if clicked:
		
		#clicked = false
		#clicked_texture.visible = false
		unselect()
		slot_unselected.emit()
	else:
		#clicked = true
		#clicked_texture.visible = true
		slot_selected.emit(self)
		
class SaveInfo:
	var index: int
	var slot_string: String
	var episode_info: String
	var location_info: String
	var date_info: String
	var empty = true
	var special_save = false #is this auto or a pointsave
	var save_path: String
