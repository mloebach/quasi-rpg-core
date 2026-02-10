extends PanelContainer

@onready var text = $HBoxContainer/Text/Text
@onready var icon = $HBoxContainer/Thumbnail/Icon
@onready var thumbnail = $HBoxContainer/Thumbnail

func _ready():
	self.hide()

func setup_tooltip_link(link: GlobalData.KeywordLink):
	text.text = link.hover_text
	if link.thumbnail_on:
		icon.texture = link.thumbnail
	else:
		thumbnail.hide()

func setup_tooltip(dict: Dictionary):
	text.text = dict["hover"]
	if dict["h_icon"] != "":
		
		icon.texture = GlobalData.get_character_icon(dict["h_icon"])
		text.text = "\"" + text.text + "\""
	else:
		thumbnail.hide()
