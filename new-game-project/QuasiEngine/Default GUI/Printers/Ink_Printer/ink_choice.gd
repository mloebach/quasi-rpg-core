extends HBoxContainer
class_name Choice

@onready var button = $Button
var choice_node : TreeNode.ChoiceNode

signal jump_selected
signal choice_selected

func load_choice(node: TreeNode.ChoiceNode):
	button.text = node.choice_summary.lstrip("\"").rstrip("\"")
	choice_node = node


func _on_button_button_up() -> void:
	#prority is indentation > set > goto > gosub > play
	
	if choice_node.args.has("goto"):
		jump_selected.emit(choice_node.goto)
	
	choice_selected.emit()
	pass # Replace with function body.
