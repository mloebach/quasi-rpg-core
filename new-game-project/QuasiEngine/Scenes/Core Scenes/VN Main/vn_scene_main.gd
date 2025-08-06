extends Node2D

@export var game_db: VN_Database

@onready var story_stage = $StoryStage

const STORY_PLAYER = preload("res://QuasiEngine/Scenes/Core Scenes/VN Main/Story Player/story_player.tscn")
var _story_player: StoryPlayer

var current_script : String
#var scene_trees : Dictionary[String, String] = {}
var played_scripts : Array[String] = []
signal switch_scene


func _ready() -> void:
	
	#if we havent loaded the data onto the global checker yet, do that
	if !GlobalData.script_data_loaded:
		_get_all_node_trees()
		GlobalData.script_data_loaded = true
	
	#initial script
	_play_scene(game_db.initial_script, 0)
	
	
func _get_all_node_trees() -> void:
	for story_file in game_db.script_pool:
		GlobalData.script_trees[story_file.script_name] = story_file.script_file
	
	
func _play_scene(scene_path: String, start_index: int) -> void:
	
	var scene_to_load = ""
	var destination_label = ""
	
	#Scene.Label = jump to label Label in scene Scene
	#Scene = jump to first point of scene
	#.Label = jump to label Label in current scene
	
	#split scene path [0] = scene, split scene path [1] = label
	var split_scene_path = scene_path.split(".", 1)
	if split_scene_path[0] == "":
		scene_to_load = current_script
	else:
		scene_to_load = split_scene_path[0]
	if split_scene_path.size() > 1:
		destination_label = split_scene_path[1]
		
	#create new story player if one doesn't exist
	if !_story_player:
		_story_player = STORY_PLAYER.instantiate()
		story_stage.add_child(_story_player)
		#add all signals here
		_story_player.scene_finished.connect(_on_scene_finished)
		_story_player.jump_into_scene.connect(_on_jump_into_scene)
		_story_player.swap_out_of_vn.connect(_on_swapping_out_of_vn)

	#edit this to feature story tree once that's in
	_story_player.load_scene(destination_label, start_index)
	if !played_scripts.has(scene_to_load):
		played_scripts.append(scene_to_load)
	
	_story_player.run_scene()

#func _read_file_content(path: String) -> String:
	#if not FileAccess.file_exists(path):
		#push_error("Could not find the script with path: %s" % path)
		#return ""
	#var file := FileAccess.open(path, FileAccess.READ)
	#var script := file.get_as_text()
	#file.close()
	#return script

#this does...nothing?
func _on_scene_finished() -> void:
	return
	
func _on_jump_into_scene(scene_to_load: String, index: int) -> void:
	_play_scene(scene_to_load, index)
	
func _on_swapping_out_of_vn(scene_to_load: String, additive: String = "false"):
	switch_scene.emit(scene_to_load, additive)
