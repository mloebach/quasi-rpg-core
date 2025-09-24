extends TextPrinter
class_name InkTextPrinter

@onready var scroll_container = $FullScreenVBox/TextHBox/MainPanel/MarginContainer/ScrollContainer
@onready var ink_scroll = $FullScreenVBox/TextHBox/MainPanel/MarginContainer/ScrollContainer/MarginContainer/InkScroll
@onready var ink_section = preload("res://QuasiEngine/Default GUI/Printers/Ink_Printer/ink_section.tscn")



var icon_queue: Array[TreeNode.IconNode]
var cg_queue: TreeNode.CGNode = null

var ink_section_array : Array[InkSection]
#var current_index = 0

#func _ready() -> void:
	#skip_author = true

#func _ready() -> void:
	#cg.visible = false

func initalize_printer(printer_data: PrinterResource):
	super(printer_data)
	clear_all_text_items()
	#print("BTW, called from ink printer!")
	
	
func set_printer_text(node: TreeNode.PrintNode):
	_create_ink_section()
	if(icon_queue.size() > 0):
		_create_icons()
	if(cg_queue != null):
		_create_cg()
	#scroll_to_bottom()
	super(node)
	#_scroll_to_bottom()
	
func _create_ink_section() -> InkSection:
	var _ink_section = ink_section.instantiate()
	ink_scroll.add_child(_ink_section)
	ink_section_array.append(_ink_section)
	_ink_section.continue_button_pressed.connect(_on_continue_button_pressed)
	_ink_section.skip_field_pressed.connect(_on_skip_field_pressed)
	return _ink_section

func _create_icons() -> void:
	#ink_section_array[ink_section_array.size()-1].icons.visible = true
	ink_section_array[ink_section_array.size()-1].show_icons()
	for icon in icon_queue:
		#var icon_string = icon.value.split(".", false, 1)
		ink_section_array[ink_section_array.size()-1].create_icon(
			GlobalData.get_character_icon(icon.id, icon.appearance)
		)
	icon_queue.clear()

func _create_cg() -> void:
	print("CG on the way!")
	#ink_section_array[ink_section_array.size()-1].icons.visible = true
	ink_section_array[ink_section_array.size()-1].show_icons()
	#ink_section_array[ink_section_array.size()-1].cg.texture = load(
		#GlobalData.game_db.cgs[cg_queue.appearance]
	#)
	
	#ink_section_array[ink_section_array.size()-1].cg.visible = true
	ink_section_array[ink_section_array.size()-1].create_cg(
		load(GlobalData.game_db.cgs[cg_queue.appearance])
	)
	cg_queue = null

func clear_all_text_items():
	for child in ink_scroll.get_children():
		child.queue_free()

func get_text_box() -> RichTextLabel:
	return ink_section_array[ink_section_array.size()-1].text_body

func await_input() -> void:
	super()
	if choice_queue.size() > 0:
		#ink_section_array[ink_section_array.size()-1].create_choice_handler()
		create_choices_on_printer()
	else:
		ink_section_array[ink_section_array.size()-1].continue_button.visible = true
	scroll_to_bottom()
	#scroll_container.set_v_scroll(scroll_container.get_v_scroll_bar().get_max())

func end_line_procedure() -> void:
	
	ink_section_array[ink_section_array.size()-1].continue_button.visible = false

#func _on_scroll_container_resized() -> void:
	#print("RESIZE CONTAIN")
	#scroll_container.set_v_scroll(ink_scroll.size.y)
func create_choice_handler() -> ChoiceHandler:
	return ink_section_array[ink_section_array.size()-1].create_choice_handler()
	#var new_choice_handler = 
	
func create_choices_on_printer():
	var reveal_time = 10000.0
	var reveal = 0 #all of them have to be anti-reveal
	if choice_queue.size() > 0:
		if choice_handler == null: #create choice handler if there isn't one
			choice_handler = create_choice_handler()
				
		for choice in choice_queue:
			choice_handler.add_choice(choice)
			if choice.args.has("time"):
				if float(choice["time"]) < reveal_time:
					reveal_time = float(choice["time"])
			else:
				reveal_time = 0.2
			if choice.args.has("show") && Util.str_to_bool(choice["show"], true) == false:
				reveal+=1
				
		
		choice_handler.jump_selected.connect(_on_jump_selected)
		#print("reveal-" + str(reveal))
		if(reveal < choice_queue.size()): #if not all choices consented to hide
			#print("revealing choices!")
			var tween = get_tree().create_tween()
			tween.tween_property(choice_handler, "modulate:a", 1.0, reveal_time).set_trans(Tween.TRANS_SINE)
		choice_queue.clear()
		
func scroll_to_bottom() -> void:
	await get_tree().create_timer(0.0).timeout #this function activates too early otherwise
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_IN_OUT)
	#print("Setting current to max - " + str(scroll_container.get_v_scroll_bar().value) + 
	#" vs " + str(scroll_container.get_v_scroll_bar().get_max()))
	
	#set_deferred("scroll_vertical", scroll_container.get_v_scroll_bar().get_max())
	var tween_time = 0.4
	if(GlobalData.game_db.sweep):
		tween_time = 0.0
	
	tween.tween_property(
		scroll_container.get_v_scroll_bar(), "value",
		scroll_container.get_v_scroll_bar().get_max(), tween_time
	 )
	
	#scroll_container.set_v_scroll(
		#scroll_container.get_v_scroll_bar().get_max()
	#)
	print("New value - " + str(scroll_container.get_v_scroll_bar().value) + 
	" vs " + str(scroll_container.get_v_scroll_bar().get_max()))

func _on_skip_field_pressed() -> void:
	early_input()
	
func _on_continue_button_pressed() -> void:
	#_awaiting_input = false
	#input_pressed.emit()
	advance_text()
	#ink_section_array[ink_section_array.size()-1].kill_skip_field()
	
