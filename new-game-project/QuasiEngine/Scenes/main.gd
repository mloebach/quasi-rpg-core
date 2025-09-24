extends Node

@export var project_scenes : Dictionary[String, PackedScene] = {
	"splash": preload("res://QuasiEngine/Scenes/Secondary Scenes/Boot_Screen/boot_scene.tscn"),
	"title": preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/title_scene_main.tscn"),
	"vn": preload("res://QuasiEngine/Scenes/Core Scenes/VN Main/vn_scene_main.tscn")
}

#currently there is just scene stage active with how the game works
@onready var scene_stage = $ActiveScene
#@onready var vn_stage = $VNStage
#@onready var menu_stage = $MenuStage

var current_scenes: Dictionary[String,Node]

func _ready()-> void:
	
	#if we dont have the main directory yet, add it
	var dir = DirAccess.open("user://")
	
	#dir.make_dir(GlobalData.game_name)
	if !dir.file_exists("user://" + GlobalData.game_name):
		dir.make_dir(GlobalData.game_name)
		var global_data = FileAccess.open(dir.get_current_dir(), FileAccess.WRITE)
		global_data.store_string("global data test")
		global_data.close()
		print("created zenith folder")
	else:
		print("user://" + GlobalData.game_name + "already exists")
	
	#boot into title screen asap. if there's anything else you wanna do
	#put it before here.
	if(GlobalData.game_db.boot_screen):
		_create_scene("splash")
	elif(GlobalData.game_db.skip_to_new):
		_create_scene("vn")
	else:
		_create_scene("title")
	
func _create_scene(scene_type: String):
	#check to see if the scene is valid to begin with
	if !project_scenes.has(scene_type):
		push_error("Scene " + scene_type + " not in script")
		return
	var new_scene = project_scenes[scene_type].instantiate()
	scene_stage.add_child(new_scene)
	new_scene.switch_scene.connect(_on_switch_scene)
	current_scenes[scene_type] = new_scene

#gets rid of everything on a stage
func _destroy_all_children(object: Node):
	var children = object.get_children()
	current_scenes.clear()
	for child in children:
		child.queue_free()

#additive is meant to layer the scenes on top of each other.
func _on_switch_scene(new_scene: String, additive: String = "false"):
	#if its not additive, destroy all current scenes first
	if(!Util.str_to_bool(additive, false)):
		_destroy_all_children(scene_stage)
	if(Util.str_to_bool(additive, false) || !current_scenes.keys().has(new_scene)):
		_create_scene(new_scene)
