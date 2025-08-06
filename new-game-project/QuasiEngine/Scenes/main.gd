extends Node

@export var project_scenes : Dictionary[String, PackedScene] = {
	"title": preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/title_scene_main.tscn"),
	"vn": preload("res://QuasiEngine/Scenes/Core Scenes/VN Main/vn_scene_main.tscn")
}

#currently there is just scene stage active with how the game works
@onready var scene_stage = $ActiveScene
#@onready var vn_stage = $VNStage
#@onready var menu_stage = $MenuStage

var current_scenes: Dictionary[String,Node]

func _ready()-> void:
	#boot into title screen asap. if there's anything else you wanna do
	#put it before here.
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
