extends Control

@onready var resolution_toggle = $Graphics/VBoxContainer/SliderVbox/Resolution/MarginContainer3/OptionButton
@onready var fullscreen_toggle = $Graphics/VBoxContainer/SliderVbox/Fullscreen/MarginContainer3/FullScreen
@onready var resizable_toggle = $Graphics/VBoxContainer/SliderVbox/Resizable/MarginContainer3/ResizeToggle


func _ready() -> void:
	resolution_toggle.selected = Settings.settings_options.current_window_size_index
	fullscreen_toggle.selected = Settings.settings_options.current_window_mode_index
	resizable_toggle.selected = Settings.settings_options.current_resizable_window_toggle
	_set_resolution_values()

func _set_resolution_values() -> void:
	resolution_toggle.clear()
	for item in Settings.display_resolutions:
		resolution_toggle.add_item(item)
	resolution_toggle.selected = Settings.settings_options.current_window_size_index


func _on_window_mode_item_selected(index: int) -> void:
	Settings.window_mode_select(index)

func _on_resize_toggle_item_selected(index: int) -> void:
	Settings.resize_toggle(index)

func _on_dimension_option_button_item_selected(index: int) -> void:
	Settings.update_window_size(index)
