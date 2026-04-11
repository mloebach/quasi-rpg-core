extends PanelContainer

const save_string = "SAVE GAME"
const load_string = "LOAD GAME"


@onready var save_label = $VBoxContainer/MarginContainer/VBoxContainer/SaveLabel
@onready var file_info = $VBoxContainer/FileInfo
@onready var load_button = $VBoxContainer/FileInfo/HBoxContainer/VBoxContainer/LoadButton
@onready var save_button = $VBoxContainer/FileInfo/HBoxContainer/VBoxContainer/SaveButton
@onready var special_save = $VBoxContainer/MarginContainer/VBoxContainer/FileSelect/MarginContainer/VBoxContainer/SaveColumns/SpecialSave
@onready var base_save = $VBoxContainer/MarginContainer/VBoxContainer/FileSelect/MarginContainer/VBoxContainer/SaveColumns/BaseSave

@onready var autosave_stage = $VBoxContainer/MarginContainer/VBoxContainer/FileSelect/MarginContainer/VBoxContainer/SaveColumns/SpecialSave/AutoVBox/AutosaveStage
@onready var pointsave_stage = $VBoxContainer/MarginContainer/VBoxContainer/FileSelect/MarginContainer/VBoxContainer/SaveColumns/SpecialSave/PointsaveStage
@onready var save_grid = $VBoxContainer/MarginContainer/VBoxContainer/FileSelect/MarginContainer/VBoxContainer/SaveColumns/BaseSave/HBox/SaveGrid

@onready var save_slot = preload("res://QuasiEngine/Scenes/Save System/save_ui/save_vbox.tscn")

@onready var slot_label = $VBoxContainer/FileInfo/HBoxContainer/FileInfo/MarginContainer/VBoxContainer/SlotLabel
@onready var ql_label = $VBoxContainer/FileInfo/HBoxContainer/FileInfo/MarginContainer/VBoxContainer/QuestLocationLabel
@onready var date_label = $VBoxContainer/FileInfo/HBoxContainer/FileInfo/MarginContainer/VBoxContainer/DateLabel

@onready var page_button_stage = $VBoxContainer/MarginContainer/VBoxContainer/FileSelect/MarginContainer/VBoxContainer/SaveColumns/BaseSave/PageButtonStage
@onready var page_button = preload("res://QuasiEngine/Scenes/Save System/save_ui/page_button.tscn")

@onready var popup_stage = $PopupStage
@onready var popup_menu = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/choice_popup_menu.tscn")

@onready var save_margin_left = $VBoxContainer/MarginContainer/VBoxContainer/FileSelect/MarginContainer/VBoxContainer/SaveColumns/BaseSave/HBox/LeftControl
@onready var save_margin_right = $VBoxContainer/MarginContainer/VBoxContainer/FileSelect/MarginContainer/VBoxContainer/SaveColumns/BaseSave/HBox/RightControl

var screenshot : Image

var menu_mode = ""
var held_path = ""
var file_menu_mode : FileManagerMenu.FileMenuMode
var current_page := 3
var page_count = 10
var slots_per_page = 9
var hover_color = Color(1.0, 1.0, 0.57, 0.188)
var hovering := false

var slot_selected : SaveSlotUI.SaveInfo

#var save_game_string = ""

signal swap_to_load_menu
signal return_to_title
signal restore_ui
signal unselect_all
signal load_selected_file


func _ready():
	_get_screenshot()
	ql_label.text = ""
	slot_label.text = ""
	date_label.text = ""
	#current_page = GlobalData.player_save.game_save_page
	_load_page_buttons()
	_load_game_saves()

func _get_screenshot():
	hide()
	screenshot = get_viewport().get_texture().get_image()
	show()


func save_mode():
	#await get_tree().create_timer(0.0).timeout
	var save_margins = 0.3
	save_margin_left.set_stretch_ratio(save_margins)
	save_margin_right.set_stretch_ratio(save_margins)
	menu_mode = save_string
	save_label.text = save_string
	load_button.hide()
	save_button.show()
	special_save.visible = false

func load_mode():
	#await get_tree().create_timer(0.0).timeout
	var save_margins = 0.1
	save_margin_left.set_stretch_ratio(save_margins)
	save_margin_right.set_stretch_ratio(save_margins)
	menu_mode = load_string
	save_label.text = load_string
	_load_special_saves()
	#_load_game_saves()
	special_save.visible = true
	load_button.show()
	save_button.hide()
	
	
func _load_page_buttons():
	current_page = GlobalData.player_save.game_save_page
	for page in page_count:
		var _page_button = page_button.instantiate()
		page_button_stage.add_child(_page_button)
		_page_button.load_text(page+1)
		_page_button.switch_to_page.connect(_on_switch_to_page)
		if page == current_page-1: #change this to have the game remember your last load page
			_page_button.disabled = true

func _on_switch_to_page(page: int):
	current_page = page
	for button in page_button_stage.get_children():
		if button.page == page:
			button.disabled = true
		else:
			button.disabled = false	
	
	#for save in save_grid.get_children():
		#save.queue_free()
	_clear_saves()
	if !slot_selected == null && !slot_selected.special_save:
		_on_slot_unselected()
		clear_text()
	_load_game_saves()

func _clear_saves():
	for save in save_grid.get_children():
		save.queue_free()

func _load_special_saves():
	_load_point_saves()
	var auto_save_slot = save_slot.instantiate()
	autosave_stage.add_child(auto_save_slot)
	#auto_save_slot.empty = false
	auto_save_slot.save_label.show()
	auto_save_slot.slot_label.hide()
	auto_save_slot.load_image_from_path("autosave")
	auto_save_slot.load_save_path("Auto Save", GlobalData.current_file_path()+"/auto.json") #put auto json path here
	#auto_save_slot.save_info.slot_string = "Auto Save"
	#auto_save_slot.save_label.text = auto_save_slot.save_info.slot_string
	auto_save_slot.save_info.special_save = true
	#auto_save_slot.mouse_hover.connect(_on_mouse_hover_over_save)
	#auto_save_slot.mouse_exit.connect(_on_mouse_exit_hover_over_save)
	_setup_slot(auto_save_slot)
		
func _load_point_saves():
	for save in GlobalData.player_save.point_saves.size():
		var point_save_slot = save_slot.instantiate()
		pointsave_stage.add_child(point_save_slot)
		point_save_slot.save_label.show()
		point_save_slot.slot_label.hide()
		#auto_save_slot.load_image_from_path("autosave")
		point_save_slot.load_save_path("Point " + str(save+1), GlobalData.current_file_path()+"/Point Saves/"+str(save)+".json")
		point_save_slot.save_info.special_save = true
		#point_save_slot.save_label.text = "Point " + str(save+1)
		_setup_slot(point_save_slot)
		
func _load_game_saves():
	var save_page = range(current_page*100, (current_page*100+slots_per_page))
	for slot in save_page:
			print("Creating slot " + str(slot))
			var game_save_slot = save_slot.instantiate()
			save_grid.add_child(game_save_slot)
			_setup_slot(game_save_slot)
			var true_slot = ((current_page-1)*slots_per_page) + (slot - (current_page*100)) + 1
			game_save_slot.save_info.index = slot
			game_save_slot.slot_label.text = str(true_slot)
			if GlobalData.player_save.game_saves.has(str(slot)):
				#var auto_save_slot = save_slot.instantiate()
				game_save_slot.save_info.empty = false
				#var true_slot = (current_page*slots_per_page) + (slot - (current_page*100))
				#game_save_slot.save_label.text = "Slot " + true_slot
				game_save_slot.load_image_from_path("Save"+str(slot))
				game_save_slot.load_save_path("Slot " + str(true_slot), GlobalData.current_file_path()+"/Manual Saves/Save"+str(slot)+".json")
				#game_save_slot.slot_string = "Slot " + str(true_slot)
				#game_save_slot.save_label = game_save_slot.slot_string
				#_setup_slot(game_save_slot)
			else:
				
				game_save_slot.save_info.slot_string = "Slot " + str(true_slot)
				#var auto_save_slot = save_slot.instantiate()
				pass
			
	
func _setup_slot(slot: SaveSlotUI):
	#slot.save_info.empty = false
	slot.mouse_hover.connect(_on_mouse_hover_over_save)
	slot.mouse_exit.connect(_on_mouse_exit_hover_over_save)
	slot.slot_selected.connect(_on_slot_selected)
	slot.slot_unselected.connect(_on_slot_unselected)
	unselect_all.connect(slot._on_unselect)
	#var auto_save_slot = save_slot.instantiate()
		
func _on_slot_selected(save: SaveSlotUI):
	#slot_label.text = "[b]" + save_info.slot_string + "[/b]"
	#ql_label.text = "Empty"
	unselect_all.emit()
	save.select()
	slot_selected = save.save_info
	#date_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	#ql_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	#slot_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	selected_label()
	if !save.save_info.empty:
		load_button.disabled = false
	else:
		load_button.disabled = true
	save_button.disabled = false
	
	#if save_info.empty:
		#slot_label.text = "[b]" + save_info.slot_string + "[/b]"
		#ql_label.text = "Empty"
	
func selected_label():
	date_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	ql_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	slot_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
func _on_slot_unselected():
	#slot_label.text = "[b]" + save_info.slot_string + "[/b]"
	#ql_label.text = "Empty"
	slot_selected = null
	date_label.modulate = hover_color
	ql_label.modulate = hover_color
	slot_label.modulate = hover_color
	load_button.disabled = true
	save_button.disabled = true
		
func _on_mouse_hover_over_save(save_info: SaveSlotUI.SaveInfo):
	date_label.modulate = hover_color
	ql_label.modulate = hover_color
	slot_label.modulate = hover_color
	hovering = true
	#ql_label.text = save_info.slot_string
	
	#if save_info.empty:
		#slot_label.text = "[b]" + save_info.slot_string + "[/b]"
		#ql_label.text = "Empty"
	#else:
		#slot_label.text = "[b]" + save_info.slot_string + "[/b]"
		#ql_label.text = save_info.episode_info + " - "+ save_info.location_info
		#date_label.text = save_info.date_info
	selected_string(save_info)
	
	#print("Hovering over autosave")
	
func clear_text():
	slot_label.text = ""
	ql_label.text = ""
	date_label.text = ""
	
func selected_string(save_info: SaveSlotUI.SaveInfo):
	if save_info.empty:
		slot_label.text = "[b]" + save_info.slot_string + "[/b]"
		ql_label.text = "Empty"
		date_label.text = ""
	else:
		slot_label.text = "[b]" + save_info.slot_string + "[/b]"
		ql_label.text = save_info.episode_info + " - "+ save_info.location_info
		date_label.text = save_info.date_info
		
func _on_mouse_exit_hover_over_save():
	hovering = false
	await get_tree().create_timer(0.1).timeout
	if !hovering: #if not hovering over new object
		if slot_selected == null:
			clear_text()
		else:
			selected_label()
			selected_string(slot_selected)
	

func _on_exit_button_button_up() -> void:
	GlobalData.player_save.game_save_page = current_page
	#has to be handled differently due to how current_file_path_works
	var path = GlobalData.main_folder + "Slot_" + str(GlobalData.player_save.file_index)+"/player.json"
	var player_data = FileAccess.open(path, FileAccess.WRITE)
	player_data.store_line(
		JSON.stringify(GlobalData.player_save.main_to_json().data)
	)
	player_data.close()
	match menu_mode:
		save_string:
			restore_ui.emit()
			queue_free()
		load_string:
			if file_menu_mode == FileManagerMenu.FileMenuMode.Load:
				swap_to_load_menu.emit()
			elif file_menu_mode == FileManagerMenu.FileMenuMode.Autoload:
				return_to_title.emit()


func _on_save_button_button_up() -> void:
	pass # Replace with function body.
	_create_popup(_save_game, _save_game_string())
		
func _create_popup(confirm_function : Callable, disclaimer_string: String = "") -> void:
	var new_popup = popup_menu.instantiate()
	popup_stage.add_child(new_popup)
	if(disclaimer_string != ""):
		new_popup.update_text(disclaimer_string)
	new_popup.pop_up_confirm.connect(confirm_function)
	
func _clear_popups():
	for popup in popup_stage.get_children():
		popup.queue_free()
	
func _save_game():
	
	screenshot.save_webp(GlobalData.current_file_path()+"/Screenshots/Save"+str(slot_selected.index)+".webp")
	_write_game_save()
	_clear_popups()
	unselect_all.emit()
	_on_slot_unselected()
	clear_text()
	_clear_saves()
	_load_game_saves()
	print("Saving game!")

func _write_game_save():
	GlobalData.player_save.main_save.date_saved = Time.get_datetime_string_from_system(false, true)
	GlobalData.player_save.main_save.variables = GlobalData.player_save.ingame_variables
	GlobalData.player_save.main_save.voyager_status = GlobalData.player_save.roster_stats
	var save_path = GlobalData.current_file_path()+"/Manual Saves/Save"+str(slot_selected.index)+".json"
	var auto = FileAccess.open(save_path, FileAccess.WRITE)
	
	auto.store_line(JSON.stringify(GlobalData.player_save.main_save.main_to_json().data))
	auto.close()
	GlobalData.player_save.game_saves[str(slot_selected.index)] = save_path
	GlobalData.save_player_file()

func _save_game_string():
	return "Save game at [b]" + slot_selected.slot_string + "[/b]?"

func _load_game_string():
	return "Load game at [b]" + slot_selected.slot_string + "[/b]?"

func _on_load_button_button_up() -> void:
	_create_popup(_load_game, _load_game_string())
	
func _load_game() -> void:
	_clear_popups()
	load_selected_file.emit(slot_selected.save_path)
