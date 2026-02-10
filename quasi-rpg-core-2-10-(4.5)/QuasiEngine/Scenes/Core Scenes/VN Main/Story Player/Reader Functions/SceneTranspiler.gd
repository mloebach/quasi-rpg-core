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
		
	func find_label(_label : String) -> int:
		var index := 0
		for node in nodes.values(): #this might be slow
			if node is TreeNode.LabelNode and node.label == _label:
				return index
			index+=1
		return -1
		
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
				
				if expression is SceneParser.BlockFunctionExpression:
					var original_value : int = story_tree.index
					story_tree.index += UNIQUE_GROUP_ID_MODIFIER
					
					
					for block in expression.value:
						pass
					
					if expression.block != null:
						var subtree := SceneParser.SyntaxTree.new()
						subtree.values = expression.block
						story_tree.index +=1
						var block_tree : StoryTree = transpile(subtree, story_tree.index)
						_copy_nodes(original_value, block_tree.nodes.keys(), story_tree, block_tree)
					#for block in expression.value:
						#var subtree := SceneParser.SyntaxTree.new()
						#subtree.values = block.value
						#story_tree.index += 1
						#var block_tree : StoryTree = transpile(subtree, story_tree.index)
						#_copy_nodes(original_value, block_tree.nodes.keys(), story_tree, block_tree)
					story_tree.index = original_value
					match expression.value:
						SceneLexer.BUILT_IN_COMMANDS.CHOICE:
							
							var choices : Array[TreeNode.ChoiceNode]
							#var original_value : int = story_tree.index

							
							
							#var initial_value = _build_value_from_symbol(expression)
							#var command_node = TreeNode.ChoiceNode.new(story_tree.index + 1, initial_value)
							var nodes : Array = _transpile_command(story_tree, expression)
							
							#9/20/25 - come back to this later
							#var branch_node = TreeNode.ChoiceBranchNode.new(story_tree.index+1, choices)
							#story_tree.append_node(branch_node)
							for node in nodes:
								story_tree.append_node(node) #get rid of this after 9/20/25
						_:
							push_warning("Unknown Boxed Command!")
				else:
					var nodes : Array = _transpile_command(story_tree, expression)
					if nodes == null: continue
					for node in nodes:
						story_tree.append_node(node)
			_:
				push_error("Unrecognized expression of type: %s with value: %s" % [expression.type, expression.value])
		
	return story_tree

func _transpile_command(story_tree: StoryTree, expression: SceneParser.BaseExpression)  -> Array[TreeNode.BaseNode]:
	var command_nodes : Array[TreeNode.BaseNode] = []
	
	transpile_index = 0
	var initial_value = _build_value_from_symbol(expression)
	
	match expression.value.to_lower():
		SceneLexer.BUILT_IN_COMMANDS.PRINT_LINE:
			var command_node = TreeNode.PrintNode.new(story_tree.index + 1, initial_value)
			command_node.args.append("text")
			command_nodes.append(command_node)
		SceneLexer.BUILT_IN_COMMANDS.BACKGROUND:
			var openingArg: String = initial_value
			var command_node
			if openingArg.split(".").size() > 1: #transition specified
				command_node = TreeNode.BGNode.new(story_tree.index + 1, openingArg.split(".")[0], 
				openingArg.split(".")[1])
				command_node.args.append_array(["appearance", "transition"])
				
			else: #transition not specified
				command_node = TreeNode.BGNode.new(story_tree.index + 1, openingArg)
				command_node.args.append("appearance")
			command_nodes.append(command_node)
		SceneLexer.BUILT_IN_COMMANDS.CG:
			var openingArg: String = initial_value
			var command_node
			if openingArg.split(".").size() > 1: #transition spacified
				command_node = TreeNode.CGNode.new(story_tree.index + 1, openingArg.split(".")[0], 
				openingArg.split(".")[1])
				command_node.args.append_array(["appearance", "transition"])
			else: #transition not specified
				command_node = TreeNode.CGNode.new(story_tree.index + 1, openingArg)
				command_node.args.append("appearance")
			command_nodes.append(command_node)
		SceneLexer.BUILT_IN_COMMANDS.CHARACTER:
			var openingArg: String = initial_value
			var command_node
			if openingArg.split(".").size() > 1: #pose specified
				command_node = TreeNode.CharNode.new(story_tree.index + 1, openingArg.split(".")[0])
				command_node._set_appearance(openingArg.split(".")[1])
				command_node.args.append_array(["id", "appearance"])
			else: #pose not specified
				command_node = TreeNode.CharNode.new(story_tree.index + 1, openingArg)
				command_node.args.append("id")
			command_nodes.append(command_node)
		SceneLexer.BUILT_IN_COMMANDS.ICON:
			var openingArg: String = initial_value
			
			var icons = openingArg.split(",", false)
			#var counter := 0
			
			print("Icon: " + openingArg)
			
			if icons.size() <= 1:
				var command_node
				if icons[0].split(".").size() > 1: #pose specified
					command_node = TreeNode.IconNode.new(story_tree.index + 1, icons[0].split(".")[0])
					command_node._set_appearance(icons[0].split(".")[1])
					command_node.args.append_array(["id", "appearance"])
				else: #pose not specified
					command_node = TreeNode.IconNode.new(story_tree.index + 1, icons[0])
					command_node.args.append("id")
				command_nodes.append(command_node)
			else:
				#var icon_symbol = SceneParser.BaseExpression.new("Symbol", icons[0])
				#var args : Array = [icon_symbol]
				#var icon_expression = SceneParser.FunctionExpression.new(
					#SceneParser.EXPRESSION_TYPES.COMMAND, 
					#SceneLexer.BUILT_IN_COMMANDS.ICON,
					#args
				#)
				#command_node = _transpile_command(story_tree, icon_expression)
				#icon_symbol = SceneParser.BaseExpression.new("Symbol", icons[1])
				#args = [icon_symbol]
				#icon_expression = SceneParser.FunctionExpression.new(
					#SceneParser.EXPRESSION_TYPES.COMMAND, 
					#SceneLexer.BUILT_IN_COMMANDS.ICON,
					#args
				#)
				#_transpile_command(story_tree, icon_expression)
				
				for index in icons.size():
					var command_node
					var icon_symbol = SceneParser.BaseExpression.new("Symbol", icons[index])
					var args : Array = [icon_symbol]
					var icon_expression = SceneParser.FunctionExpression.new(
						SceneParser.EXPRESSION_TYPES.COMMAND, 
						SceneLexer.BUILT_IN_COMMANDS.ICON,
						args
					)
					command_node = _transpile_command(story_tree, icon_expression)
					command_nodes.append_array(command_node)
					
					if index < (icons.size()-1):
						story_tree.index+=1
				story_tree.index-=1
					##icon_expression.arguments.add(icon_symbol)
					##icon_expression.value = 
					#_transpile_command(story_tree, icon_expression)
				#return
				#if icons[index].split(".").size() > 1: #pose specified
					#command_node = TreeNode.IconNode.new(story_tree.index + 1 + counter, icons[index].split(".")[0])
					#command_node._set_appearance(icons[index].split(".")[1])
					#command_node.args.append_array(["id", "appearance"])
				#else: #pose not specified
					##command_node = TreeNode.IconNode.new(story_tree.index + 1 +counter, icons[index])
					##command_node.args.append("id")
				#counter += 1
				#if index == icons.size()-1:
					#story_tree.index += 1
		SceneLexer.BUILT_IN_COMMANDS.SUMMON_PRINTER:
			
			var openingArg: String = initial_value
			var command_node
			if openingArg.split(".").size() > 1: #pose specified
				command_node = TreeNode.PrinterNode.new(story_tree.index + 1, openingArg.split(".")[0], 
				openingArg.split(".")[1])
				command_node.args.append_array(["id", "appearance"])
			else: #pose not specified
				command_node = TreeNode.PrinterNode.new(story_tree.index + 1, openingArg)
				command_node.args.append("id")
			command_nodes.append(command_node)
		SceneLexer.BUILT_IN_COMMANDS.SUMMON_VIEWPORT:	
			var openingArg: String = initial_value
			var command_node
			if openingArg.split(".").size() > 1: #transition spacified
				command_node = TreeNode.ViewportNode.new(story_tree.index + 1, openingArg.split(".")[0], 
				openingArg.split(".")[1])
				command_node.args.append_array(["id", "appearance"])
			else: #transition not specified
				command_node = TreeNode.ViewportNode.new(story_tree.index + 1, openingArg)
				command_node.args.append("id")
			command_nodes.append(command_node)
		SceneLexer.BUILT_IN_COMMANDS.CHOICE:
			var command_node
			if expression is not SceneParser.BlockFunctionExpression:
				command_node = TreeNode.ChoiceNode.new(story_tree.index + 1, initial_value)
			else:
				command_node = TreeNode.ChoiceNode.new(story_tree.index + 1 +UNIQUE_GROUP_ID_MODIFIER, initial_value)
			command_nodes.append(command_node)
		SceneLexer.BUILT_IN_COMMANDS.PLAY_BGM:
			#var openingArg: String = expression.arguments[0].value
			#command_node = BGMCommandNode.new(story_tree.index + 1, expression.arguments[0].value)
			var command_node
			var openingArg: String = initial_value
			if openingArg.split(".").size() > 1: #pose specified
				command_node = TreeNode.BGMNode.new(story_tree.index + 1, openingArg.split(".")[0], openingArg.split(".")[1])
				command_node.args.append_array(["audioPath", "clip"])
			else: #pose not specified
				command_node = TreeNode.BGMNode.new(story_tree.index + 1, openingArg)
				command_node.args.append("audioPath")
			command_nodes.append(command_node)
		SceneLexer.BUILT_IN_COMMANDS.PLAY_SFX:
			var command_node = TreeNode.SFXNode.new(story_tree.index + 1, initial_value)
			command_node.args.append("audioPath")
			command_nodes.append(command_node)
		SceneLexer.BUILT_IN_COMMANDS.PLAY_VOICE:
			var command_node = TreeNode.VoiceNode.new(story_tree.index + 1, initial_value)
			command_node.args.append("audioPath")
			command_nodes.append(command_node)
		SceneLexer.BUILT_IN_COMMANDS.MOVIE:
			var command_node = TreeNode.MovieNode.new(story_tree.index +1, initial_value)
			command_node.args.append("movieName")
			command_nodes.append(command_node)
		SceneLexer.BUILT_IN_COMMANDS.OPEN_URL:
			var command_node = TreeNode.UrlNode.new(story_tree.index+1, initial_value)
			command_node.args.append("url")
			command_nodes.append(command_node)
		SceneLexer.BUILT_IN_COMMANDS.WAIT:
			var command_node = TreeNode.WaitNode.new(story_tree.index + 1, initial_value)
			command_node.args.append("waitTime")
			command_nodes.append(command_node)
		SceneLexer.BUILT_IN_COMMANDS.SET_VARIABLE, \
		SceneLexer.DEBUG_COMMANDS.FIRST_SCRIPT:
			var command_node = TreeNode.SetNode.new(story_tree.index + 1, initial_value)
			command_node.args.append("expression")
			command_nodes.append(command_node)
		SceneLexer.BUILT_IN_COMMANDS.LOAD_SCENE:
			command_nodes.append(TreeNode.SceneSwapNode.new(story_tree.index+1, initial_value))
		SceneLexer.BUILT_IN_COMMANDS.GROUP, \
		SceneLexer.BUILT_IN_COMMANDS.RANDOM:
			var subtree := SceneParser.SyntaxTree.new()
			for line in expression.block:
				pass
		SceneLexer.BUILT_IN_COMMANDS.JUMP_TO, \
		SceneLexer.BUILT_IN_COMMANDS.SUBSCRIPT_JUMP_TO, \
		SceneLexer.BUILT_IN_COMMANDS.SUBSCRIPT_RETURN:
			var command_node = TreeNode.JumpNode.new(story_tree.index+1, initial_value)
			command_node.args.append("path")
			command_nodes.append(command_node)
		SceneLexer.BUILT_IN_COMMANDS.STOP_SCRIPT, \
		SceneLexer.BUILT_IN_COMMANDS.CLEAR_INK, \
		SceneLexer.BUILT_IN_COMMANDS.STOP_VOICE, \
		SceneLexer.BUILT_IN_COMMANDS.LOAD_TITLE:
			command_nodes.append(TreeNode.CommandNode.new(story_tree.index + 1))
		SceneLexer.BUILT_IN_COMMANDS.STOP_BGM, \
		SceneLexer.BUILT_IN_COMMANDS.STOP_SFX:
			command_nodes.append(TreeNode.AudioNode.new(story_tree.index + 1))
		#CustomCommands.CUSTOM_COMMANDS:
			#command_node = CustomCommands.CustomNode.new(story_tree.index + 1)
		_:
			var custcom = CustomCommands.new()
			if custcom.custom_commands.find_key(expression.value):
				print("Custom command ACTIVATE")
				var command_node = GlobalData.custom_command_functions.transpile_custom_command(initial_value, story_tree, expression)
				command_nodes.append(command_node)
				#command_node = CustomCommands.CustomNode.new(story_tree.index + 1)
			else:
				push_error("Unrecognized command type `%s`" % expression.value)
				
	#now that it's figured out its identity, load its args into it
	#it has to be bigger than one bc i think one is the smallest
	if command_nodes.size() <= 1:
		var command_node = command_nodes[0]
		if command_node != null && expression.arguments.size() > 1:
			assert(command_nodes.size() <= 1) # debug for multiple sizes
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
					elif(arg_name == "set"):
						command_node["set_variable"] = arg_value
						command_node.args.append("set_variable")
					else:
						command_node[arg_name] = arg_value
						command_node.args.append(arg_name)
				
		if command_node == null:
			push_error("We don't know this command! - " + expression.value)
			#return command_nodes
		command_node["command"] = expression.value
	#print(str(expression.value," CommandNode:", command_node))
	return command_nodes


#adds nodes from source tree to target tree
func _copy_nodes(original_value: int, nodes: Array, target_tree: StoryTree, source_tree: StoryTree)->void:
	#source_tree.append_node() #there was a pass command node here
	nodes.append(source_tree.nodes.keys().back())
	
	#add source trees notde to target tree
	for node in nodes:
		target_tree.nodes[node] = source_tree.nodes[node]
		target_tree.index += 1

#this is here to turn symbols back into one entity, ex score="Matt" would be two entities
func _build_value_from_symbol(expression: SceneParser.BaseExpression):
	var arg_value := ""
	while(transpile_index < expression.arguments.size() &&
		expression.arguments[transpile_index].type == SceneLexer.TOKEN_TYPES.SYMBOL
	):
		arg_value += expression.arguments[transpile_index].value
		transpile_index+=1
	return arg_value
	
