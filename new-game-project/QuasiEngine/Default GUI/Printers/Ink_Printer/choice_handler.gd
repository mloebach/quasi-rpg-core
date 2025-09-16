extends PanelContainer
class_name ChoiceHandler

@onready var choice_stage = $MarginContainer/ChoiceVbox
@onready var choice = preload("res://QuasiEngine/Default GUI/Printers/Ink_Printer/ink_choice.tscn")

signal jump_selected

func load_handler(node: TreeNode.ChoiceNode):
	pass
	
func add_choice(node: TreeNode.ChoiceNode):
	var new_choice = choice.instantiate()
	choice_stage.add_child(new_choice)
	new_choice.load_choice(node)
	new_choice.jump_selected.connect(_on_jump_selected)
	new_choice.choice_selected.connect(_on_choice_selected)
	
func _on_jump_selected(goto: String):
	jump_selected.emit(goto)
	
func _on_choice_selected():
	queue_free()
