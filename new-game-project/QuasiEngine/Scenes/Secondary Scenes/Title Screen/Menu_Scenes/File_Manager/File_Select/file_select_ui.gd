extends PanelContainer

@onready var file_button = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/File_Select/file_button.tscn")
@onready var file_button_vbox = $"VBoxContainer/File Stage"

signal swap_to_load_player_menu
signal swap_to_new_player_menu

func _ready() -> void:
	_load_file_buttons()

func _load_file_buttons() -> void:
	for index in GlobalData.global_save.player_saves.size():
		var save_button = file_button.instantiate()
		file_button_vbox.add_child(save_button)
		save_button.set_file_number((index+1))
		save_button.file_selected.connect(_on_file_selected)
		
		if(GlobalData.global_save.player_saves[index] != null):
			#print(GlobalData.global_save.player_saves[index])
			save_button.load_file_info(GlobalData.global_save.player_saves[index])
			
			
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
