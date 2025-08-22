extends Node
class_name StoryPlayer

const KEY_END_OF_SCENE := -1

@onready var _printer_stage = $"UILayer/MainUIVBox/PrimaryUIStage/Printer Stage"

@onready var ribbon_ui_stage = $UILayer/MainUIVBox/RibbonUIStage
@onready var upper_ui_stage = $UILayer/UpperUI
@onready var popup_stage = $UILayer/UpperUI/Popup_Stage

var _printer_objects: Dictionary[String, Node] = {}

@onready var ink_printer = preload("res://QuasiEngine/Scenes/Core Scenes/VN Main/Resources/UI/Printers/ink_text_printer.tscn")

@onready var ribbon_ui = preload("res://QuasiEngine/Scenes/Core Scenes/VN Main/Resources/UI/ribbon_ui.tscn")
@onready var popup_ui = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/choice_popup_menu.tscn")
@onready var settings_menu = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/settings_menu.tscn")

var _scene_data := {}
var _starting_index := 0
var _input_command := false
var _wait_command := true
#var _auto_on := false

var text_printer : TextPrinter
var gosub_stack : Array[ScenarioLine]

signal scene_finished #current scene has run out of content
signal jump_into_scene #end current scene early for new scene 
signal swap_out_of_vn #when there needs to be a scene that isnt a vn
#

@export var title_screen_disclaimer_string = "Do you want to return to the title screen?"


func _ready() -> void:
	_load_ribbon_ui()



func load_scene(story: SceneTranspiler.StoryTree, label: String, index: int) -> void:
	_scene_data = story.nodes
	if label != "" && story.find_label(label) != -1:
		_starting_index = story.find_label(label) + index
	else:
		_starting_index = index
	return
	
	
func run_scene() -> void:
	print("running!")
	var key : int = _starting_index
	await get_tree().create_timer(0.0).timeout 
	while key < _scene_data.size() && key != KEY_END_OF_SCENE:
		print("key " + str(key))
		var node: TreeNode.BaseNode = _scene_data[key]
		#var newActor : Node
		var expressionCheck = ExpressionFunctions.new()
		_input_command = false
		
		if node is TreeNode.LabelNode:
			key = node.next
			continue
			
		#change {} to variables they represent
		for arg in node.args:
			var _sifted_array : PackedStringArray
			var _left_side : PackedStringArray = node[arg].split("{")
			for cut_string in _left_side:
				_sifted_array.append_array(cut_string.split("}"))
			#the odd ones are expressions
			for index in _sifted_array.size():
				if index % 2 == 1:
					_sifted_array[index] = expressionCheck.display_variable(_sifted_array[index], node)
			node[arg] = "".join(_sifted_array)
		
		#this is where the function that keeps track of which commands have happened would go
		#i forgot the use case for it if there was one. the scope of it (global vs player vs save) wasnt clear so im not implementing yet
			
		#check conditional
		if node is TreeNode.CommandNode && node.conditional != "":
			
			if !expressionCheck.check_conditional(node): #if conditional is false...
				key = node.next #move on
				continue
	
		var _new_actor = _evaluate_node(node, key)
		
		#if we jump, we don't care about the current script loop anymore.
		if node is TreeNode.CommandNode && node.command == SceneLexer.BUILT_IN_COMMANDS.JUMP_TO:
			break
		#special case for @stop
		if node is TreeNode.CommandNode && node.command == SceneLexer.BUILT_IN_COMMANDS.STOP_SCRIPT:
			key = KEY_END_OF_SCENE
			continue
		if _new_actor != null && _wait_command:
			await _new_actor.command_done
		if _new_actor != null && _input_command:
			await _new_actor.end_print_line
			_input_command = false
		print("next key is " + str(node.next))
		key = node.next
	
	scene_finished.emit()
	
	return
	
func _evaluate_node(node: TreeNode.BaseNode, key: int):
	var _new_actor : Node
	var _actor_functions = ActorFunctions.new(self)
	match node.command:
		SceneLexer.BUILT_IN_COMMANDS.PRINT_LINE:
			_new_actor = _print_command(node)
			_input_command = true
		SceneLexer.BUILT_IN_COMMANDS.ICON:
			_new_actor = _icon_command(node)
		SceneLexer.BUILT_IN_COMMANDS.CG:
			_new_actor = _cg_command(node)
		SceneLexer.BUILT_IN_COMMANDS.JUMP_TO:
			jump_into_scene.emit(node.path, 0)
			#var scenario_line = ScenarioLine.new(node.path, key)
			#gosub_stack.push_back(scenario_line)
		SceneLexer.BUILT_IN_COMMANDS.STOP_SCRIPT:
			#stop script's meat isnt here but also we dont want to get an error
			pass
		_:
			print("Command failed to process! - " + str(node))
	
	return _new_actor


func _print_command(node : TreeNode.PrintNode):
	print("Printing: " + node.text)
	
	#summon text printer
	
	#if we don't have text printer...
	if text_printer == null:
		#load the printer resource file of the default printer from DB
		var printer_resource = GlobalData.printers[GlobalData.game_db.default_printer]
		
		text_printer = _instantiate_object(
			GlobalData.game_db.default_printer,
			_printer_objects,
			_printer_stage,
			printer_resource.printer_object
		)
		_printer_objects[GlobalData.game_db.default_printer].initalize_printer(printer_resource)
		
	text_printer.set_printer_text(node)
	return text_printer
	
func _icon_command(node: TreeNode.IconNode):
	if text_printer is InkTextPrinter:
		print("Icon command is valid!")
		text_printer.icon_queue.append(node)
		
func _cg_command(node: TreeNode.CGNode):
	if text_printer is InkTextPrinter:
		print("CG command is valid!")
		text_printer.cg_queue = node
	else:
		print("Implementing CG!")
		
	
func _instantiate_object(_actorID: String, _storage : Dictionary[String,Node], _stage: Node, _asset: PackedScene) -> Node:
	_storage[_actorID] = _asset.instantiate()
	_storage[_actorID].name = _actorID
	_stage.add_child(_storage[_actorID])
	return _storage[_actorID]

func _create_popup(confirm_function : Callable, disclaimer_string: String = "") -> void:
	var new_popup = popup_ui.instantiate()
	popup_stage.add_child(new_popup)
	if(disclaimer_string != ""):
		new_popup.update_text(disclaimer_string)
	new_popup.pop_up_confirm.connect(confirm_function)

func _load_ribbon_ui()-> void:
	var _ribbon_ui = ribbon_ui.instantiate()
	ribbon_ui_stage.add_child(_ribbon_ui)
	_ribbon_ui.create_settings_menu.connect(_on_create_settings_menu)
	_ribbon_ui.return_to_title.connect(_on_title_button_clicked)
	#_ribbon_ui.auto_toggled.connect(_on_auto_toggled)
	
	
#func _on_auto_toggled(auto_status : bool) -> void:
	#_auto_on = auto_status
	
func _on_create_settings_menu() -> void:
	var new_settings_menu = settings_menu.instantiate()
	upper_ui_stage.add_child(new_settings_menu)
	
func _on_title_button_clicked() -> void:
	_create_popup(_on_return_to_title, title_screen_disclaimer_string)
	
func _on_return_to_title()-> void:
	swap_out_of_vn.emit("title")
	
class ScenarioLine:	
	var index : int
	var label : String

	func _init(_label: String, _index: int) -> void:
		self.index = _index
		self.label = _label
