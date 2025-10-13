extends PanelContainer

@onready var icon_image = $MarginContainer/TextureRect


func change_icon(texture: Texture2D):
	icon_image.texture = texture
