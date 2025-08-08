class_name SceneTranspiler
extends RefCounted

#modifiers to add to the indexes of all group 
const UNIQUE_GROUP_ID_MODIFIER := 10000000000
const UNIQUE_CONDITIONAL_ID_MODIFIER := 21000000000

const ERROR_NONEXISTANT_JUMP := -3

var transpile_index 

#tree of nodes representing a scene. all nodes are inside dictionary
class StoryTree:
	var nodes := {}
	var index := 0
	
	func append_node(node: TreeNode.BaseNode) -> void:
		nodes[index] = node
		index += 1
		
#takes in syntax tree created from the parser and turns it into story tree usable by story player
func transpile(syntax_tree: SceneParser.SyntaxTree, start_index: int) -> StoryTree:
	var story_tree := StoryTree.new()
	story_tree.index = start_index
	while not syntax_tree.is_at_end():
		var expression: SceneParser.BaseExpression = syntax_tree.move_to_next_expression()
		match expression.type:
			SceneParser.EXPRESSION_TYPES.LABEL:
				var node := TreeNode.LabelNode.new(story_tree.index+1, expression.value)
				story_tree.append_node(node)
			SceneParser.EXPRESSION_TYPES.COMMAND:
				var node := _transpile_command(story_tree, expression)
				if node == null: continue
				story_tree.append_node(node)
			_:
				push_error("Unrecognized expression of type: %s with value: %s" % [expression.type, expression.value])
		
	return story_tree

func _transpile_command(story_tree: StoryTree, expression: SceneParser.BaseExpression)  -> TreeNode.BaseNode:
	var command_node : TreeNode.BaseNode = null
	
	transpile_index = 0
	var initial_value = _build_value_from_symbol(expression)
	
	match expression.value:
		SceneLexer.BUILT_IN_COMMANDS.PRINT_LINE:
			command_node = TreeNode.PrintNode.new(story_tree.index + 1, initial_value)
			command_node.args.append("text")
		SceneLexer.BUILT_IN_COMMANDS.BACKGROUND:
			var openingArg: String = initial_value
			if openingArg.split(".").size() > 1: #transition specified
				command_node = TreeNode.BGNode.new(story_tree.index + 1, openingArg.split(".")[0], 
				openingArg.split(".")[1])
				command_node.args.append_array(["appearance", "transition"])
			else: #transition not specified
				command_node = TreeNode.BGNode.new(story_tree.index + 1, openingArg)
				command_node.args.append("appearance")
		SceneLexer.BUILT_IN_COMMANDS.CG:
			var openingArg: String = initial_value
			if openingArg.split(".").size() > 1: #transition spacified
				command_node = TreeNode.CGNode.new(story_tree.index + 1, openingArg.split(".")[0], 
				openingArg.split(".")[1])
				command_node.args.append_array(["appearance", "transition"])
			else: #transition not specified
				command_node = TreeNode.CGNode.new(story_tree.index + 1, openingArg)
				command_node.args.append("appearance")
		SceneLexer.BUILT_IN_COMMANDS.CHARACTER:
			var openingArg: String = initial_value
			if openingArg.split(".").size() > 1: #pose specified
				command_node = TreeNode.CharNode.new(story_tree.index + 1, openingArg.split(".")[0])
				command_node._set_appearance(openingArg.split(".")[1])
				command_node.args.append_array(["id", "appearance"])
			else: #pose not specified
				command_node = TreeNode.CharNode.new(story_tree.index + 1, openingArg)
				command_node.args.append("id")
		SceneLexer.BUILT_IN_COMMANDS.SUMMON_PRINTER:
			var openingArg: String = initial_value
			if openingArg.split(".").size() > 1: #pose specified
				command_node = TreeNode.PrinterNode.new(story_tree.index + 1, openingArg.split(".")[0], 
				openingArg.split(".")[1])
				command_node.args.append_array(["id", "appearance"])
			else: #pose not specified
				command_node = TreeNode.PrinterNode.new(story_tree.index + 1, openingArg)
				command_node.args.append("id")
		SceneLexer.BUILT_IN_COMMANDS.SUMMON_VIEWPORT:	
			var openingArg: String = initial_value
			if openingArg.split(".").size() > 1: #transition spacified
				command_node = TreeNode.ViewportNode.new(story_tree.index + 1, openingArg.split(".")[0], 
				openingArg.split(".")[1])
				command_node.args.append_array(["id", "appearance"])
			else: #transition not specified
				command_node = TreeNode.ViewportNode.new(story_tree.index + 1, openingArg)
				command_node.args.append("id")
		SceneLexer.BUILT_IN_COMMANDS.PLAY_BGM:
			#var openingArg: String = expression.arguments[0].value
			#command_node = BGMCommandNode.new(story_tree.index + 1, expression.arguments[0].value)
			var openingArg: String = initial_value
			if openingArg.split(".").size() > 1: #pose specified
				command_node = TreeNode.BGMNode.new(story_tree.index + 1, openingArg.split(".")[0], openingArg.split(".")[1])
				command_node.args.append_array(["audioPath", "clip"])
			else: #pose not specified
				command_node = TreeNode.BGMNode.new(story_tree.index + 1, openingArg)
				command_node.args.append("audioPath")
		SceneLexer.BUILT_IN_COMMANDS.PLAY_SFX:
			command_node = TreeNode.SFXNode.new(story_tree.index + 1, initial_value)
			command_node.args.append("audioPath")
		SceneLexer.BUILT_IN_COMMANDS.PLAY_VOICE:
			command_node = TreeNode.VoiceNode.new(story_tree.index + 1, initial_value)
			command_node.args.append("audioPath")
		SceneLexer.BUILT_IN_COMMANDS.MOVIE:
			command_node = TreeNode.MovieNode.new(story_tree.index +1, initial_value)
			command_node.args.append("movieName")
		SceneLexer.BUILT_IN_COMMANDS.WAIT:
			command_node = TreeNode.WaitNode.new(story_tree.index + 1, initial_value)
			command_node.args.append("waitTime")
		SceneLexer.BUILT_IN_COMMANDS.SET_VARIABLE:
			command_node = TreeNode.SetNode.new(story_tree.index + 1, initial_value)
			command_node.args.append("expression")
		SceneLexer.BUILT_IN_COMMANDS.LOAD_SCENE:
			command_node = TreeNode.SceneSwapNode.new(story_tree.index+1, initial_value)
		SceneLexer.BUILT_IN_COMMANDS.GROUP, \
		SceneLexer.BUILT_IN_COMMANDS.RANDOM:
			var subtree := SceneParser.SyntaxTree.new()
			for line in expression.block:
				pass
		SceneLexer.BUILT_IN_COMMANDS.JUMP_TO, \
		SceneLexer.BUILT_IN_COMMANDS.SUBSCRIPT_JUMP_TO, \
		SceneLexer.BUILT_IN_COMMANDS.SUBSCRIPT_RETURN:
			command_node = TreeNode.JumpNode.new(story_tree.index+1, initial_value)
			command_node.args.append("path")
		SceneLexer.BUILT_IN_COMMANDS.STOP_SCRIPT, \
		SceneLexer.BUILT_IN_COMMANDS.STOP_VOICE, \
		SceneLexer.BUILT_IN_COMMANDS.LOAD_TITLE:
			command_node = TreeNode.CommandNode.new(story_tree.index + 1)
		SceneLexer.BUILT_IN_COMMANDS.STOP_BGM, \
		SceneLexer.BUILT_IN_COMMANDS.STOP_SFX:
			command_node = TreeNode.AudioNode.new(story_tree.index + 1)
		_:
			push_error("Unrecognized command type `%s`" % expression.value)
				
	#now that it's figured out its identity, load its args into it
	#it has to be bigger than one bc i think one is the smallest
	if command_node != null && expression.arguments.size() > 1:
		for arg in expression.arguments.slice(transpile_index):
			if(arg.type == SceneLexer.TOKEN_TYPES.PARAMETER):
				var arg_name = arg.value
				#if(transpile_index+1 < expression.arguments.size()):
				#	pass
				transpile_index+=1
				var arg_value = _build_value_from_symbol(expression)
				#conditionals whose internals dont match how theyre called via script
				if(arg_name == "if"):
					command_node["conditional"] = arg_value
				elif(arg_name == "as"):
					command_node["authorOverride"] = arg_value
					command_node.args.append("authorOverride")
				else:
					command_node[arg_name] = arg_value
					command_node.args.append(arg_name)
				
	if command_node == null:
		push_error("We don't know this command! - " + expression.value)
		return command_node
	command_node["command"] = expression.value
	print(str(expression.value," CommandNode:", command_node))
	return command_node

#this is here to turn symbols back into one entity, ex score="Matt" would be two entities
func _build_value_from_symbol(expression: SceneParser.BaseExpression):
	var arg_value := ""
	while(transpile_index < expression.arguments.size() &&
		expression.arguments[transpile_index].type == SceneLexer.TOKEN_TYPES.SYMBOL
	):
		arg_value += expression.arguments[transpile_index].value
		transpile_index+=1
	return arg_value
	
