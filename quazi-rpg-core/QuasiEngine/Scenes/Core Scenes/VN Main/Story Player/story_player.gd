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
@onready var save_menu = preload("res://QuasiEngine/Scenes/Save System/save_menu.tscn")

@onready var ribbon_ui = preload("res://QuasiEngine/Scenes/Core Scenes/VN Main/Resources/UI/ribbon_ui.tscn")
@onready var popup_ui = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/choice_popup_menu.tscn")
@onready var settings_menu = preload("res://QuasiEngine/Scenes/Secondary Scenes/Title Screen/Menu_Scenes/File_Manager/settings_menu.tscn")

var key : int
var _scene_data := {}
var _starting_index := 0
var _input_command := false
var _wait_command := true
var break_story_loop := false

#var subscript_stack: Array[ScenarioLine]

#var _auto_on := false

var text_printer : TextPrinter
#var choice_handler: ChoiceHandler
#var choice_queue: Array[TreeNode.ChoiceNode]
var gosub_stack : Array[ScenarioLine]

signal scene_finished #current scene has run out of content
signal jump_into_scene #end current scene early for new scene 
signal swap_out_of_vn #when there needs to be a scene that isnt a vn
#signal stack_subscript



#change variable type if ever you need to shift commands
#@export var custom_command_type = ZenithCustomCommands
#var custom_command_functions

#

@export var title_screen_disclaimer_string = "Do you want to return to the title screen?"


func _ready() -> void:
	_skip_to_new_funcs()
	_load_ribbon_ui()
	if !Settings.settings_options.tts_toggle:
		tts_toggle_text.visible = false
	else:
		tts_toggle_text.visible = true



func load_scene(story: SceneTranspiler.StoryTree, label: String, index: int) -> void:
	_scene_data.clear()
	_scene_data = story.nodes.duplicate()
	if label != "" && story.find_label(label) != -1:
		print("found label!")
		_starting_index = story.find_label(label) + index
	else:
		if label != "":
			push_warning("Label not found! :" + label)
		_starting_index = index
	return
	
	
func run_scene() -> void:
	print("running!")
	key = _starting_index
	
	#load printer if there is one
	if GlobalData.player_save.main_save.active_printer != "" && text_printer == null:
		print("get printer back in here!")
		_load_printer(GlobalData.player_save.main_save.active_printer)
	else:
		if text_printer == null:
			#print("we don't need to load printer yet")
			print("load default printer")
			_load_printer(GlobalData.game_db.default_printer)
	
	await get_tree().create_timer(0.0).timeout 
	while key < _scene_data.size() && key != KEY_END_OF_SCENE:
		#print("key " + str(key))
		#var node = TreeNode.BaseNode.new(_scene_data[key].next)
		#node = _scene_data[key]
		var node: TreeNode.BaseNode = _scene_data[key]
			
		var expressionCheck = ExpressionFunctions.new()
		_input_command = false
		
		if node is TreeNode.LabelNode:
			key = node.next
			continue
			
		var original_args := {}
			
		for arg in node.args:
			original_args[arg] = node[arg]
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
			
			if !expressionCheck.check_conditional(node.conditional): #if conditional is false...
				key = node.next #move on
				continue
	
	
		
	
		var _new_actor = _evaluate_node(node, key)
		
		
		
		#if we jump, we don't care about the current script loop anymore.
		if node is TreeNode.CommandNode && (
				[
					SceneLexer.BUILT_IN_COMMANDS.JUMP_TO,
					SceneLexer.BUILT_IN_COMMANDS.SUBSCRIPT_JUMP_TO,
					SceneLexer.BUILT_IN_COMMANDS.SUBSCRIPT_RETURN,
				].has(node.command)
			):
			#node = original_node
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
			if break_story_loop:
				break_story_loop = false
				break
			
			
		#print("next key is " + str(node.next))
		#node = original_node
		print("Restoring Vars! - " +node.command)
		for arg in original_args:
			node[arg] = original_args[arg]
		key = node.next
	
	scene_finished.emit()
	
	return
	
func _evaluate_node(node: TreeNode.BaseNode, key: int):
	var _new_actor : Node
	var _actor_functions = ActorFunctions.new(self)
	print("Command - " + node.command)
	match node.command.to_lower():
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
		SceneLexer.BUILT_IN_COMMANDS.SET_VARIABLE:	
			_set_ingame_variable(node)
		SceneLexer.BUILT_IN_COMMANDS.CLEAR_INK:
			_new_actor = _clear_ink_printer()
		SceneLexer.BUILT_IN_COMMANDS.OPEN_URL:
			_new_actor = _open_url(node)
		SceneLexer.BUILT_IN_COMMANDS.JUMP_TO:
			var jump_node = TreeNode.JumpNode.new(node.next, node.path)
			copy_args(jump_node, node)
			
			jump_into_scene.emit(jump_node.path, 0)
			#var scenario_line = ScenarioLine.new(node.path, key)
			#gosub_stack.push_back(scenario_line)
		SceneLexer.BUILT_IN_COMMANDS.SUBSCRIPT_JUMP_TO:
			#stack_subscript.emit(ScenarioLine.new(GlobalData.current_script, key))
			print("Gosub entering!")
			#var current_label = GlobalData.current_script + "." + GlobalData.current_label
			#var current_label = GlobalData.current_script
			#GlobalData.subscript_stack.append(ScenarioLine.new(current_label, node.next))
			#jump_into_scene.emit(node.path, 0)
			#_on_gosub_selected(node.path, node.next)
			var current_label = GlobalData.current_script
			GlobalData.subscript_stack.append(ScenarioLine.new(current_label, node.next))
			jump_into_scene.emit(node.path, 0)
		SceneLexer.BUILT_IN_COMMANDS.SUBSCRIPT_RETURN:
			#jump_into_scene.emit
			print("Gosub exiting!")
			var return_line = GlobalData.subscript_stack.pop_back()
			jump_into_scene.emit(return_line.label, return_line.index)
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


func _skip_to_new_funcs():
	if GlobalData.game_db.skip_to_new:
		if !GlobalData.ingame_variables.has("zenith_name"):
			GlobalData.ingame_variables["zenith_name"] = "ZENITH"

#func _get_printer():
	#if text_printer == null:
		#return "null"
	#else:
		#return text_printer.printer_type


func _print_command(node : TreeNode.PrintNode):
	#print("Printing: " + node.text)
	
	#summon text printer
	
	#if we don't have text printer...
	if text_printer == null:
		_load_printer(GlobalData.game_db.default_printer)
		#load the printer resource file of the default printer from DB
		#var printer_resource = GlobalData.printers[GlobalData.game_db.default_printer]
		#
		#text_printer = _instantiate_object(
			#GlobalData.game_db.default_printer,
			#_printer_objects,
			#_printer_stage,
			#printer_resource.printer_object
		#)
		#
		##text_printer.printer_type = GlobalData.game_db.default_printer
		#GlobalData.player_save.main_save.active_printer = GlobalData.game_db.default_printer
		#text_printer.jump_selected.connect(_on_jump_selected)
		#_printer_objects[GlobalData.game_db.default_printer].initalize_printer(printer_resource)
		
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
	
	
func _load_printer(printer_name: String):
	var printer_resource = GlobalData.printers[printer_name]
		
	text_printer = _instantiate_object(
		printer_name,
		_printer_objects,
		_printer_stage,
		printer_resource.printer_object
	)
		
		#text_printer.printer_type = GlobalData.game_db.default_printer
	GlobalData.player_save.main_save.active_printer = printer_name
	text_printer.jump_selected.connect(_on_jump_selected)
	text_printer.gosub_selected.connect(_on_gosub_selected)
	_printer_objects[printer_name].initalize_printer(printer_resource)
#func _create_choices_on_printer():
	#if text_printer.choice_queue.size() > 0:
		#if choice_handler == null: #create choice handler if there isn't one
			#if text_printer is InkTextPrinter:
				#choice_handler = text_printer.create_choice_handler()
				#choice_handler.jump_selected.connect(_on_jump_selected)
		#for choice in text_printer.choice_queue:
			#choice_handler.add_choice(choice)
		#text_printer.choice_queue.clear()
	
func copy_args(new_node, old_node):
	new_node["args"] = old_node["args"]
	for arg in old_node["args"]:
			new_node[arg] = old_node[arg]
	
func _clear_ink_printer():
	if text_printer is InkTextPrinter:
		print("Clear command is valid!")
		text_printer.clear_all_text_items()
	
func _open_url(node: TreeNode.UrlNode):
	var url_node = TreeNode.UrlNode.new(node.next, node.url)
	copy_args(url_node, node)
	
	print("Opening URL: " + url_node.url)
	OS.shell_open(url_node.url)
	
func _icon_command(node: TreeNode.IconNode):
	if text_printer is InkTextPrinter:
		print("Icon command is valid!")
		
		var icon_node = TreeNode.IconNode.new(node.next, node.id)
		copy_args(icon_node, node)
		#var icons = icon_node.id.split(",")
		
		text_printer.icon_queue.append(icon_node)
		
		#for icon in icons.size():
			#var new_node = TreeNode.IconNode.new(node.next, node.id)
			#create printer if there isnt one, and let it be default
			#text_printer.icon_queue.append(icons[icon])
		
func _create_choice(node: TreeNode.ChoiceNode):
	
	print("loading choice!")
	#_wait_command = false
	
	var choice_node = TreeNode.ChoiceNode.new(node.next, node.choice_summary)
	copy_args(choice_node, node)
	
	if text_printer != null:
		text_printer.choice_queue.append(choice_node)
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
		var cg_node = TreeNode.CGNode.new(node.next, node.appearance)
		copy_args(cg_node, node)
		text_printer.cg_queue = node
	else:
		print("Implementing CG!")
		
func _set_ingame_variable(node : TreeNode.SetNode):
	var expression_check = ExpressionFunctions.new()
	var set_node = TreeNode.SetNode.new(node.next, node.expression)
	copy_args(set_node, node)
	expression_check.set_variable(node.expression)
	
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
	_ribbon_ui.create_save_menu.connect(_on_create_save_menu)
	_ribbon_ui.auto_toggled.connect(_on_auto_toggled)
	
	
func _on_auto_toggled(auto_status : bool) -> void:
	#_auto_on = auto_status
	GlobalData.auto_printer_on = auto_status
	
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
	new_status_menu.load_icons(GlobalData.player_save.roster_stats)


func _on_create_save_menu() -> void:
	var new_save_menu = save_menu.instantiate()
	upper_ui_stage.add_child(new_save_menu)
	main_stage.visible = false
	new_save_menu.save_mode()
	new_save_menu.restore_ui.connect(_restore_ui)

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
	GlobalData.current_scene_status = GlobalData.SceneTypes.out_of_game
	GlobalData.save_player_file()
	#GlobalData.global_save.current_player_slot
	swap_out_of_vn.emit("title")
	
func _on_jump_selected(goto: String):
	
	jump_into_scene.emit(goto, 0)
	break_story_loop = true
	
func _on_gosub_selected(path: String, next: int):
	var current_label = GlobalData.current_script
	GlobalData.subscript_stack.append(ScenarioLine.new(current_label, next))
	jump_into_scene.emit(path, 0)
	break_story_loop = true
	
class ScenarioLine:	
	var index : int
	var label : String

	func _init(_label: String, _index: int) -> void:
		self.index = _index
		self.label = _label
