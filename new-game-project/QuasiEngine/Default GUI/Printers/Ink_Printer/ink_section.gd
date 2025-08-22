extends PanelContainer
class_name InkSection

@onready var icon_stage = $Margins/VBox/IconVbox/Icons
#@onready var skip_area = $SkipField

@onready var icons = $Margins/VBox/IconVbox
@onready var base_icon = preload("res://QuasiEngine/Default GUI/Printers/Ink_Printer/ink_icon.tscn")
@onready var text_body = $Margins/VBox/TextBody
@onready var cg = $Margins/VBox/IconVbox/Cgs/CG

@onready var continue_button = $Margins/VBox/ContinueHbox/Button

signal continue_button_pressed
signal skip_field_pressed

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

func create_icon(texture : Texture2D) -> void:
	var new_icon = base_icon.instantiate()
	icon_stage.add_child(new_icon)
	new_icon.change_icon(texture)

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
	continue_button_pressed.emit()


#func _on_skip_field_button_up() -> void:
	#print("Skip Field Pressed")
	#skip_field_pressed.emit()
	#kill_skip_field()
	#
#func kill_skip_field() -> void:
	#if skip_area != null:
		#skip_area.queue_free()
