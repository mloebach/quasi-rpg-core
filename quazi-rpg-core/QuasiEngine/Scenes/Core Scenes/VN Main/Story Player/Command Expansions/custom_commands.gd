extends SceneLexer
class_name CustomCommands

#const CUSTOM_COMMANDS := {
	#STATUS_MENU = "status"
#}
var custom_command_sets := [
	ZenithCustomCommands.new()
	#ZenithCustomCommands.CUSTOM_COMMANDS
]

var custom_commands := {
	
}

func _init() -> void:
	print("initializing custom comms")
	for command_set in custom_command_sets:
		for command in command_set.CUSTOM_COMMANDS:
			print("custom command " + command)
			custom_commands[command] = command_set.CUSTOM_COMMANDS[command]

#class CustomNode:
	#extends TreeNode.BaseNode
	#
	#var command: String
	#var args := []
	#
	#var wait: String
	#var conditional: String = ""
	#
	#func _init(_next: int) -> void:
		#super(_next)
