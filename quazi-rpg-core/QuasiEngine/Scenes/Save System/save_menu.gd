extends PanelContainer

const save_string = "SAVE GAME"
const load_string = "LOAD GAME"


@onready var save_label = $VBoxContainer/MarginContainer/VBoxContainer/SaveLabel
@onready var file_info = $VBoxContainer/FileInfo
@onready var load_button = $VBoxContainer/FileInfo/HBoxContainer/VBoxContainer/LoadButton
@onready var save_button = $VBoxContainer/FileInfo/HBoxContainer/VBoxContainer/SaveButton
@onready var special_save = $VBoxContainer/MarginContainer/VBoxContainer/FileSelect/MarginContainer/VBoxContainer/SaveColumns/SpecialSave
@onready var base_save = $VBoxContainer/MarginContainer/VBoxContainer/FileSelect/MarginContainer/VBoxContainer/SaveColumns/BaseSave

@onready var autosave_stage = $VBoxContainer/MarginContainer/VBoxContainer/FileSelect/MarginContainer/VBoxContainer/SaveColumns/SpecialSave/AutosaveStage
@onready var pointsave_stage = $VBoxContainer/MarginContainer/VBoxContainer/FileSelect/MarginContainer/VBoxContainer/SaveColumns/SpecialSave/PointsaveStage
@onready var save_grid = $VBoxContainer/MarginContainer/VBoxContainer/FileSelect/MarginContainer/VBoxContainer/SaveColumns/BaseSave/HBox/SaveGrid

@onready var save_slot = preload("res://QuasiEngine/Scenes/Save System/save_ui/save_vbox.tscn")

@onready var slot_label = $VBoxContainer/FileInfo/HBoxContainer/FileInfo/MarginContainer/VBoxContainer/SlotLabel
@onready var ql_label = $VBoxContainer/FileInfo/HBoxContainer/FileInfo/MarginContainer/VBoxContainer/QuestLocationLabel
@onready var date_label = $VBoxContainer/FileInfo/HBoxContainer/FileInfo/MarginContainer/VBoxContainer/DateLabel

@onready var page_button_stage = $VBoxContainer/MarginContainer/VBoxContainer/FileSelect/MarginContainer/VBoxContainer/SaveColumns/BaseSave/PageButtonStage
@onready var page_button = preload("res://QuasiEngine/Scenes/Save System/save_ui/page_button.tscn")


var menu_mode = ""
var file_menu_mode : FileManagerMenu.FileMenuMode
var current_page := 1
var page_count = 9
var slots_per_page = 9
var hover_color = Color(1.0, 1.0, 0.57, 0.188)
var hovering := false

var slot_selected : SaveSlotUI.SaveInfo

signal swap_to_load_menu
signal return_to_title
signal restore_ui
signal unselect_all


func _ready():
	ql_label.text = ""
	slot_label.text = ""
	date_label.text = ""
	_load_page_buttons()
	_load_game_saves()

func save_mode():
	menu_mode = save_string
	save_label.text = save_string
	load_button.hide()
	save_button.show()
	special_save.visible = false

func load_mode():
	menu_mode = load_string
	save_label.text = load_string
	_load_special_saves()
	#_load_game_saves()
	special_save.visible = true
	load_button.show()
	save_button.hide()
	
	
func _load_page_buttons():
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
	
	for save in save_grid.get_children():
		save.queue_free()
	if !slot_selected == null && !slot_selected.special_save:
		_on_slot_unselected()
		clear_text()
	_load_game_saves()

func _load_special_saves():
	_load_point_saves()
	var auto_save_slot = save_slot.instantiate()
	autosave_stage.add_child(auto_save_slot)
	#auto_save_slot.empty = false
	auto_save_slot.save_label.show()
	
	auto_save_slot.load_image_from_path("autosave")
	auto_save_slot.load_save_path("Auto Save", GlobalData.current_file_path()+"/auto.json") #put auto json path here
	auto_save_slot.save_info.special_save = true
	#auto_save_slot.mouse_hover.connect(_on_mouse_hover_over_save)
	#auto_save_slot.mouse_exit.connect(_on_mouse_exit_hover_over_save)
	_setup_slot(auto_save_slot)
		
func _load_point_saves():
	for save in GlobalData.player_save.point_saves.size():
		var point_save_slot = save_slot.instantiate()
		pointsave_stage.add_child(point_save_slot)
		point_save_slot.save_label.show()
		#auto_save_slot.load_image_from_path("autosave")
		point_save_slot.load_save_path("Point Save " + str(save+1), GlobalData.current_file_path()+"/Point Saves/"+str(save)+".json")
		point_save_slot.save_info.special_save = true
		point_save_slot.save_label.text = "Point " + str(save+1)
		_setup_slot(point_save_slot)
		
func _load_game_saves():
	var save_page = range(current_page*100, (current_page*100+slots_per_page))
	for slot in save_page:
			print("Creating slot " + str(slot))
			var game_save_slot = save_slot.instantiate()
			save_grid.add_child(game_save_slot)
			_setup_slot(game_save_slot)
			var true_slot = ((current_page-1)*slots_per_page) + (slot - (current_page*100)) + 1
			if GlobalData.player_save.game_saves.has(slot):
				#var auto_save_slot = save_slot.instantiate()
				game_save_slot.empty = false
				#var true_slot = (current_page*slots_per_page) + (slot - (current_page*100))
				#game_save_slot.save_label.text = "Slot " + true_slot
				game_save_slot.load_save_path("Slot " + str(true_slot), GlobalData.current_file_path()+"/Manual Saves/"+slot+".json")
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
	match menu_mode:
		save_string:
			restore_ui.emit()
			queue_free()
		load_string:
			if file_menu_mode == FileManagerMenu.FileMenuMode.Load:
				swap_to_load_menu.emit()
			elif file_menu_mode == FileManagerMenu.FileMenuMode.Autoload:
				return_to_title.emit()
