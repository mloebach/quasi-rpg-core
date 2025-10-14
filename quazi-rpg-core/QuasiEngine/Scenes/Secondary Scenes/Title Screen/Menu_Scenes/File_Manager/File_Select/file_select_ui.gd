extends PanelContainer
class_name FileSelect

@onready var file_button = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/File_Select/file_button.tscn")
@onready var file_button_vbox = $"VBoxContainer/File Stage"

signal swap_to_load_player_menu
signal swap_to_new_player_menu
signal erase_mode_on
signal copy_mode_on
signal exit_to_normal
signal which_slot_to_copy

signal erase_selected_file
signal option_selected

var mode = FileSelectMode.Normal

enum FileSelectMode {
	Normal,
	Erase,
	CopyWhichFile,
	CopyToSlot
}

func _ready() -> void:
	_load_file_buttons()

func _load_file_buttons() -> void:
	for index in GlobalData.global_save.player_names.size():
		var save_button = file_button.instantiate()
		file_button_vbox.add_child(save_button)
		save_button.set_file_number((index+1))
		save_button.file_selected.connect(_on_file_selected)
		erase_mode_on.connect(save_button._on_erase_mode_on)
		copy_mode_on.connect(save_button._on_copy_mode_on)
		save_button.which_slot_to_copy.connect(_on_which_slot_to_copy)
		which_slot_to_copy.connect(save_button._on_which_to_copy)
		exit_to_normal.connect(save_button._on_exit_to_normal)
		save_button.erase_selected_file.connect(_on_erase_selected_file)
		
		save_button.option_confirmed.connect(_on_option_confirmed)
		
		if(GlobalData.global_save.player_names[index] != ""):
			#print(GlobalData.global_save.player_saves[index])
			var json = FileAccess.open(GlobalData.global_save.get_save_at_slot(index), FileAccess.READ)
			print("load player save: " + GlobalData.global_save.get_save_at_slot(index))
			save_button.load_file_info(GlobalData.player_save.load_save(json))
			
			
func _unload_file_buttons() -> void:
	for button in file_button_vbox.get_children():
		button.queue_free()
			
func _on_file_selected(file_button : PlayerFileButton):
	
	
	if file_button.file_status == PlayerFileButton.FileStatus.SavedFile:
		
		swap_to_load_player_menu.emit(file_button.player_file, file_button.file_index-1)
		#_swap_to_load(file_button.player_file)
	elif file_button.file_status == PlayerFileButton.FileStatus.NewFile:
		#print("new file!")
		swap_to_new_player_menu.emit(file_button.file_index-1)
		#_swap_to_new()

func _on_choose_erase_file():
	mode = FileSelectMode.Erase
	erase_mode_on.emit()

func _on_copy_mode_on():
	mode = FileSelectMode.CopyWhichFile
	copy_mode_on.emit()

func _on_exit_to_normal():
	mode = FileSelectMode.Normal
	exit_to_normal.emit()

func _on_which_slot_to_copy(index: int):
	mode = FileSelectMode.CopyToSlot
	which_slot_to_copy.emit(index)

func _on_erase_selected_file(index: int):
	erase_selected_file.emit(index)

func _on_option_confirmed():
	_on_exit_to_normal()
	option_selected.emit()
