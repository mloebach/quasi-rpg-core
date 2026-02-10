extends PanelContainer

@onready var icon_image = $MarginContainer/TextureRect
var character_tag = ""
signal create_tooltip
signal destroy_tooltip

func change_icon(texture: Texture2D):
	icon_image.texture = texture


func _on_texture_rect_mouse_entered() -> void:
	create_tooltip.emit(character_tag)
	

func _on_texture_rect_mouse_exited() -> void:
	destroy_tooltip.emit()
