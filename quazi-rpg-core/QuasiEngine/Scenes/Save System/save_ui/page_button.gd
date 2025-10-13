extends Button

var page : int

signal switch_to_page

#func _ready():
	#switch_to_page.connect(_on_switch_to_page)


func load_text(_text: int):
	text = str(_text)
	page = _text


func _on_button_up() -> void:
	switch_to_page.emit(page)

#func _on_switch_to_page(_page):
	#if page != _page:
		#disabled = false
	#else:
		#disabled = true
