extends PanelContainer
class_name InkSection

@onready var icon_stage = $Margins/VBox/IconVbox/Icons
@onready var cg_stage = $Margins/VBox/IconVbox/Cgs
#@onready var skip_area = $SkipField

@onready var icons = $Margins/VBox/IconVbox
@onready var base_icon = preload("res://QuasiEngine/Default GUI/Printers/Ink_Printer/ink_icon.tscn")
@onready var base_cg = preload("res://QuasiEngine/Default GUI/Printers/Ink_Printer/ink_cg.tscn")
@onready var text_body = $Margins/VBox/TextBody
#@onready var cg = $Margins/VBox/IconVbox/Cgs/CG

@onready var continue_button = $Margins/VBox/ContinueSection/ContinueHandler/Button
@onready var choice_handler = preload("res://QuasiEngine/Default GUI/Printers/Ink_Printer/ink_choice_handler.tscn")
@onready var continue_stage = $Margins/VBox/ContinueSection

signal continue_button_pressed
signal skip_field_pressed

signal create_hover
signal destroy_hover


func _ready() -> void:
	continue_button.hide()
	icons.visible = false
	icons.modulate.a = 0.0
	modulate.a = 0.0
	_show_panel()
	
func _show_panel() -> void:
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(
		self, "modulate:a",
		1.0, 0.3
	 )
	
func _load_text(_text: String) -> void:
	text_body.text = _text

func create_icon(texture : Texture2D, id: String) -> void:
	var new_icon = base_icon.instantiate()
	icon_stage.add_child(new_icon)
	new_icon.change_icon(texture)
	new_icon.character_tag = id
	new_icon.create_tooltip.connect(_on_icon_create_hover)
	new_icon.destroy_tooltip.connect(_on_hover_destroy)

func create_cg(texture : Texture2D) -> void:
	var new_cg = base_cg.instantiate()
	cg_stage.add_child(new_cg)
	new_cg.change_cg(texture)
	
func create_choice_handler() -> ChoiceHandler:
	var _choice_handler = choice_handler.instantiate()
	continue_stage.add_child(_choice_handler)
	_choice_handler.play_next_line.connect(_on_button_button_up) #this is interchangable with continue button
	return _choice_handler
	

func show_icons() -> void:
	icons.visible = true
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(
		icons, "modulate:a",
		1.0, 0.5
	 )
 
func _on_button_button_up() -> void:
	if(!GlobalData.printer_paused):
		continue_button_pressed.emit()


#func _on_skip_field_button_up() -> void:
	#print("Skip Field Pressed")
	#skip_field_pressed.emit()
	#kill_skip_field()
	#
#func kill_skip_field() -> void:
	#if skip_area != null:
		#skip_area.queue_free()


func _on_text_body_meta_clicked(meta: Variant) -> void:
	var json = JSON.new()
	json.parse(meta)
	if json.data.has("hover"): #abort if it has hover in there
		return
	#print("%s versus %s - out of %s" % [text_body.visible_characters,json.data.pos, text_body.text.length()])
	if text_body.visible_characters > json.data.pos || text_body.visible_characters == -1:
		print(str(meta))


func _on_text_body_meta_hover_started(meta: Variant) -> void:
	var json = JSON.new()
	json.parse(meta)
	##print("%s versus %s - out of %s" % [text_body.visible_characters,json.data.pos, text_body.text.length()])
	##await 
	#if text_body.visible_characters > json.data.pos || text_body.visible_characters == -1:
	create_hover.emit(json.data)

func _on_icon_create_hover(id: String):
	var hover_data : Dictionary = {"wiki":id, "pos":0}
	create_hover.emit(hover_data)

func _on_text_body_meta_hover_ended(meta: Variant) -> void:
	#destroy_hover.emit()
	_on_hover_destroy()

func _on_hover_destroy():
	destroy_hover.emit()
