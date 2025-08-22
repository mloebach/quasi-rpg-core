extends Control

@onready var resolution_toggle = $VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MainSettings/PanelContainer/TabContainer/Graphics/Graphics/VBoxContainer/SliderVbox/Resolution/MarginContainer3/OptionButton
@export var default_res_option := 2

#var resolutions : Dictionary[String,Vector2] = {
	#"1920x1080" = Vector2(1920,1080),
	#"1280x720" = Vector2(1920,1080),
#}

@export var resolution_array : Array[String]

func _ready() -> void:
	_set_resolution_values()
	#_update_window_size(GlobalData.current_window_size_index)

func _set_resolution_values() -> void:
	resolution_toggle.clear()
	for item in resolution_array:
		#resolutionArray.append(item)
		resolution_toggle.add_item(item)
	resolution_toggle.selected = default_res_option

func _on_yes_button_button_up() -> void:
	_save_settings()
	
func _save_settings() -> void:
	pass
	queue_free()


func _on_no_button_button_up() -> void:
	queue_free()

#func _adjust_window_mode() -> void:
	
func _resolution_string_to_vector(res : String) -> Vector2:
	
	var split_string = res.split("x", false, 1)
	var dimensions := Vector2(
		int(split_string[0].strip_edges()), int(split_string[1].strip_edges())
	)
	
	return dimensions

func _on_window_mode_item_selected(index: int) -> void:
	#windowed = 0, fullscreen = 1, borderless = 2
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			_update_window_size(GlobalData.current_window_size_index)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		_:
			push_error("Window mode not found!")


func _on_resize_toggle_item_selected(index: int) -> void:
	match index:
		0: 
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)
		1:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, false)


func _on_dimension_option_button_item_selected(index: int) -> void:
	#get_viewport().size = _resolution_string_to_vector(resolution_array[index])
	_update_window_size(index)
	
func _update_window_size(index: int):
	GlobalData.current_window_size_index = index
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		get_viewport().size = _resolution_string_to_vector(resolution_array[index])
		
