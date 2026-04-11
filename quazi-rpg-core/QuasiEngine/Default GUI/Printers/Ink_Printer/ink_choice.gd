extends HBoxContainer
class_name Choice

#@onready var button = $Button
@onready var button = $MarginContainer/Button
#@onready var button_text = $Button/Margins/ButtonText
@onready var button_text = $MarginContainer/ButtonText
var choice_node : TreeNode.ChoiceNode

signal jump_selected
signal gosub_selected
signal choice_selected
signal play_next_line

func load_choice(node: TreeNode.ChoiceNode):
	
	button_text.text = node.choice_summary.lstrip("\"").rstrip("\"")
	choice_node = node
	if Util.str_to_bool(node.disable, false):
		button.disabled = true
		button_text.modulate.a = 0.3


func _on_button_button_up() -> void:
	#prority is indentation > set > goto > gosub > play
	
	if choice_node.args.has("set_variable"):
		print("setting variable!")
		var expression_check = ExpressionFunctions.new()
		expression_check.set_variable(choice_node.set_variable)
	
	if choice_node.args.has("goto"):
		jump_selected.emit(choice_node.goto)
		choice_selected.emit()
		return
	
	if choice_node.args.has("gosub"):
		gosub_selected.emit(choice_node.gosub)
		choice_selected.emit()
		return
		
	if choice_node.args.has("play") && Util.str_to_bool(choice_node["play"], false):
		
		play_next_line.emit()
		choice_selected.emit()
		return
	
	pass # Replace with function body.
