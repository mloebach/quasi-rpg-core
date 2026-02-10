extends TextureRect

#@onready var icon_image = $MarginContainer/TextureRect


func change_cg(_texture: Texture2D):
	texture = _texture
