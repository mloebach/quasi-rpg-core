extends TextPrinter
class_name DialogueTextPrinter

@onready var main_text = $VBoxContainer/TextHbox/PanelContainer/MarginContainer/MainText
@onready var speaker_text = $VBoxContainer/AuthorHbox/PanelContainer/MarginContainer/SpeakerText


func initalize_printer(printer_data: PrinterResource):
	super(printer_data)
	main_text.text = ""
	speaker_text.text = ""
	print("BTW, called from main printer!")


func clear_text():
	main_text.clear()
	main_text.text = ""

func get_text_box() -> RichTextLabel:
	return main_text

func get_author_text_box() -> RichTextLabel:
	return speaker_text


func _on_speaker_text_meta_clicked(meta: Variant) -> void:
	print("Clicked on link-" + str(meta))
	pass # Replace with function body.


func _on_main_text_meta_clicked(meta: Variant) -> void:
	print("Clicked on link-" + str(meta))
	pass # Replace with function body.
