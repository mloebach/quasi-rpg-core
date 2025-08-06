extends Node2D

@onready var quit_menu = $"Upper Layer/Quit Menu"

signal switch_scene



func _on_quit_button_pressed() -> void:
	quit_menu.visible = true
	pass # Replace with function body.



func _on_quit_yes_button_pressed() -> void:
	get_tree().quit()


func _on_quit_no_button_pressed() -> void:
	quit_menu.visible = false


func _on_new_game_button_button_up() -> void:
	switch_scene.emit("vn")
