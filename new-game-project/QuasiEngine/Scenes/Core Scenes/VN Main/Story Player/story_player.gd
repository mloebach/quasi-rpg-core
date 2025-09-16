extends Node
class_name StoryPlayer

const KEY_END_OF_SCENE := -1

@onready var main_stage = $UILayer/MainUIVBox

@onready var _printer_stage = $"UILayer/MainUIVBox/PrimaryUIStage/Printer Stage"

@onready var ribbon_ui_stage = $UILayer/MainUIVBox/RibbonUIStage
@onready var upper_ui_stage = $UILayer/UpperUI
@onready var popup_stage = $UILayer/UpperUI/Popup_Stage

@onready var tts_toggle_text = $UILayer/UpperUI/TopLevelUI/TTSEnabledText

var _printer_objects: Dictionary[String, Node] = {}

@onready var ink_printer = preload("res://QuasiEngine/Scenes/Core Scenes/VN Main/Resources/UI/Printers/ink_text_printer.tscn")

@onready var status_menu = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/status_menu.tscn")

@onready var ribbon_ui = preload("res://QuasiEngine/Scenes/Core Scenes/VN Main/Resources/UI/ribbon_ui.tscn")
@onready var popup_ui = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/choice_popup_menu.tscn")
@onready var settings_menu = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/settings_menu.tscn")

var _scene_data := {}
var _starting_index := 0
var _input_command := false
var _wait_command := true
#var _auto_on := false

var text_printer : TextPrinter
#var choice_handler: ChoiceHandler
#var choice_queue: Array[TreeNode.ChoiceNode]
var gosub_stack : Array[ScenarioLine]

signal scene_finished #current scene has run out of content
signal jump_into_scene #end current scene early for new scene 
signal swap_out_of_vn #when there needs to be a scene that isnt a vn


#change variable type if ever you need to shift commands
#@export var custom_command_type = ZenithCustomCommands
#var custom_command_functions

#

@export var title_screen_disclaimer_string = "Do you want to return to the title screen?"


func _ready() -> void:
	
	_load_ribbon_ui()
	if !Settings.tts_toggle:
		tts_toggle_text.visible = false
	else:
		tts_toggle_text.visible = true



func load_scene(story: SceneTranspiler.StoryTree, label: String, index: int) -> void:
	_scene_data = story.nodes
	if label != "" && story.find_label(label) != -1:
		print("found label!")
		_starting_index = story.find_label(label) + index
	else:
		push_warning("Label not found! " + label)
		_starting_index = index
	return
	
	
func run_scene() -> void:
	print("running!")
	var key : int = _starting_index
	await get_tree().create_timer(0.0).timeout 
	while key < _scene_data.size() && key != KEY_END_OF_SCENE:
		#print("key " + str(key))
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
		#print("next key is " + str(node.next))
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
		SceneLexer.BUILT_IN_COMMANDS.CHOICE:
			#_new_actor = _create_choice(node)
			_create_choice(node)
		SceneLexer.BUILT_IN_COMMANDS.CLEAR_INK:
			_new_actor = _clear_ink_printer(node)
		SceneLexer.BUILT_IN_COMMANDS.JUMP_TO:
			jump_into_scene.emit(node.path, 0)
			#var scenario_line = ScenarioLine.new(node.path, key)
			#gosub_stack.push_back(scenario_line)
		SceneLexer.DEBUG_COMMANDS.FIRST_SCRIPT:
			GlobalData.opening_script = node.expression
		SceneLexer.BUILT_IN_COMMANDS.STOP_SCRIPT:
			#stop script's meat isnt here but also we dont want to get an error
			pass
		_:
			#var custom_command_funcs = CustomCommandFunctions.new()
			var custom_comms = CustomCommands.new()
			if custom_comms.custom_commands.find_key(node.command):
				print("Custom Command GO!")
				GlobalData.custom_command_functions.evaluate_node(node)
			else:
				print("Command failed to process! - " + str(node))
	
	return _new_actor


func _print_command(node : TreeNode.PrintNode):
	#print("Printing: " + node.text)
	
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
		
		text_printer.jump_selected.connect(_on_jump_selected)
		_printer_objects[GlobalData.game_db.default_printer].initalize_printer(printer_resource)
		
	text_printer.set_printer_text(node)
	#_create_choices_on_printer()
	#if choice_queue.size() > 0:
		#if choice_handler == null: #create choice handler if there isn't one
			#if text_printer is InkTextPrinter:
				#choice_handler = text_printer.create_choice_handler()
				#choice_handler.jump_selected.connect(_on_jump_selected)
		#for choice in choice_queue:
			#choice_handler.add_choice(choice)
		#choice_queue.clear()
	return text_printer
	
#func _create_choices_on_printer():
	#if text_printer.choice_queue.size() > 0:
		#if choice_handler == null: #create choice handler if there isn't one
			#if text_printer is InkTextPrinter:
				#choice_handler = text_printer.create_choice_handler()
				#choice_handler.jump_selected.connect(_on_jump_selected)
		#for choice in text_printer.choice_queue:
			#choice_handler.add_choice(choice)
		#text_printer.choice_queue.clear()
	
func _clear_ink_printer(node: TreeNode.CommandNode):
	if text_printer is InkTextPrinter:
		print("Clear command is valid!")
		text_printer.clear_all_text_items()
	
func _icon_command(node: TreeNode.IconNode):
	if text_printer is InkTextPrinter:
		print("Icon command is valid!")
		text_printer.icon_queue.append(node)
		
func _create_choice(node: TreeNode.ChoiceNode):
	
	print("loading choice!")
	#_wait_command = false
	if text_printer != null:
		text_printer.choice_queue.append(node)
	#if text_printer is InkTextPrinter:
		#choice_queue.append(node)
	
	#if choice_handler == null: #create choice handler if there isn't one
		#if text_printer is InkTextPrinter:
			#choice_handler = text_printer.create_choice_handler()
			#choice_handler.jump_selected.connect(_on_jump_selected)
	#choice_handler.add_choice(node)
		
		
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
	_ribbon_ui.create_status_menu.connect(_on_create_status_menu)
	#_ribbon_ui.auto_toggled.connect(_on_auto_toggled)
	
	
#func _on_auto_toggled(auto_status : bool) -> void:
	#_auto_on = auto_status
	
func _on_create_settings_menu() -> void:
	var new_settings_menu = settings_menu.instantiate()
	upper_ui_stage.add_child(new_settings_menu)
	main_stage.visible = false
	new_settings_menu.restore_ui.connect(_restore_ui)
	new_settings_menu.tts_toggled.connect(_on_tts_toggled)
	
func _on_create_status_menu() -> void:
	var new_status_menu = status_menu.instantiate()
	upper_ui_stage.add_child(new_status_menu)
	main_stage.visible = false
	new_status_menu.restore_ui.connect(_restore_ui)


func _on_tts_toggled(index: int) -> void:
	match index:
		0:
			tts_toggle_text.visible = false
		1:
			tts_toggle_text.visible = true
		_:
			push_warning("Unknown value processed.")
	
func _on_title_button_clicked() -> void:
	_create_popup(_on_return_to_title, title_screen_disclaimer_string)
	
func _restore_ui() -> void:
	GlobalData.printer_paused = false
	main_stage.visible = true
	
func _on_return_to_title()-> void:
	GlobalData.printer_paused = false
	swap_out_of_vn.emit("title")
	
func _on_jump_selected(goto: String):
	jump_into_scene.emit(goto, 0)
	
class ScenarioLine:	
	var index : int
	var label : String

	func _init(_label: String, _index: int) -> void:
		self.index = _index
		self.label = _label
