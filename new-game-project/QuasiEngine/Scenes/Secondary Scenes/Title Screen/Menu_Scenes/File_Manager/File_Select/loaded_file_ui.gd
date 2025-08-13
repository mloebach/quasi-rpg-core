extends PanelContainer

signal swap_to_file_select_menu
signal return_to_title()
#signal swap_to_new_player_menu
var file_menu_mode : FileManagerMenu.FileMenuMode


func _on_return_button_button_up() -> void:
	if file_menu_mode == FileManagerMenu.FileMenuMode.Load:
		swap_to_file_select_menu.emit()
	elif file_menu_mode == FileManagerMenu.FileMenuMode.Autoload:
		return_to_title.emit()
