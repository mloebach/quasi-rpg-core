extends StoryPlayer


class_name ZenithCustomCommands

const CUSTOM_COMMANDS := {
	STATUS_MENU = "status",
	UNLOCK_EP = "unlock_ep"
}


func transpile_custom_command(initial_value: String, story_tree: SceneTranspiler.StoryTree, expression: SceneParser.BaseExpression):
	var command_node
	match expression.value:
		CUSTOM_COMMANDS.STATUS_MENU:
			var opening_arg: String = initial_value
			if opening_arg.split().size() > 1:
				command_node = StatusNode.new(story_tree.index +1, opening_arg.split(".")[0], opening_arg.split(".")[1])
				command_node.args.append_array(["character", "status"])
			else:
				command_node = StatusNode.new(story_tree.index +1, opening_arg.split(".")[0], "active")
				#automatically set character to active if no status specified
			
	return command_node
	

func evaluate_node(node : TreeNode.BaseNode):
	var _new_actor : Node
	var _actor_functions = ActorFunctions.new(self)
	match node.command:
		ZenithCustomCommands.CUSTOM_COMMANDS.STATUS_MENU:
			update_status(node)
	return _new_actor


func update_status(node : StatusNode):
	
	match node.status.to_lower():
		"active":
			GlobalData.custom_global_data.roster_stats[node.character].status = Zenith_Global_Data.CharacterStatus.Active
		"eliminated":
			GlobalData.custom_global_data.roster_stats[node.character].status = Zenith_Global_Data.CharacterStatus.Eliminated
		"unknown":
			GlobalData.custom_global_data.roster_stats[node.character].status = Zenith_Global_Data.CharacterStatus.Unknown
		_:
			push_error("Unknown status from @status: " + node.status)
	
	
	
	print("Status updated! ")

#COMMAND NODES
class StatusNode:
	extends TreeNode.CommandNode
	
	var character: String
	var status: String
	
	func _init(_next: int, _char: String, _status: String) -> void:
		super(_next)
		character = _char
		status = _status
