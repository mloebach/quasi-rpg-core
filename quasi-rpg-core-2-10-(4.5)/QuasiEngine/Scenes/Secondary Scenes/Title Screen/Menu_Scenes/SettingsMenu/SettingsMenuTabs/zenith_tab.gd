extends Control


@onready var zenith_label = $"MarginContainer/VBoxContainer/HBoxContainer/Zenith Label"
@onready var rename_button = $MarginContainer/VBoxContainer/RenamePlayer/MarginContainer2/NameButton
@onready var rename_counter = $MarginContainer/VBoxContainer/RenamePlayer/MarginContainer3/ChanceLabel
@onready var color_label = $MarginContainer/VBoxContainer/PlayerColor/MarginContainer/ColorLabel
@onready var color_picker = $MarginContainer/VBoxContainer/PlayerColor/MarginContainer2/ColorPickerButton
@onready var pronoun_label = $MarginContainer/VBoxContainer/PlayerPronouns/MarginContainer/PronounsLabel
@onready var pronoun_toggle = $MarginContainer/VBoxContainer/PlayerPronouns/MarginContainer2/PronounToggle

signal create_name_field

func _ready() -> void:
	#resolution_toggle.selected = Settings.settings_options.current_window_size_index
	color_picker.color = Color.from_string(GlobalData.player_save.z_color, Color.SLATE_GRAY)
	pronoun_toggle.selected = GlobalData.player_save.z_pronouns
	set_zenith_labels()
	
	
	
func set_zenith_labels():
	zenith_label.text = "%s Options" % GlobalData.player_save.player_name
	rename_button.text = GlobalData.player_save.player_name
	rename_counter.text = "%s Left" % GlobalData.player_save.z_renames_left
	color_label.text = "%s Color" % GlobalData.player_save.player_name
	pronoun_label.text = "%s Pronouns" % GlobalData.player_save.player_name
	if GlobalData.player_save.z_renames_left == 0:
		rename_button.disabled = true

func _on_update_z_tab():
	set_zenith_labels()


func _on_pronoun_toggle_item_selected(index: int) -> void:
	GlobalData.player_save.z_pronouns = index as Zenith_Global_Data.Pronouns
	GlobalData.save_player_file()


func _on_color_picker_button_color_changed(color: Color) -> void:
	GlobalData.player_save.z_color = color.to_html()
	GlobalData.save_player_file()


func _on_name_button_button_up() -> void:
	create_name_field.emit()
