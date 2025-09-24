extends PanelContainer
class_name ChoiceHandler

@onready var choice_stage = $MarginContainer/ChoiceVbox
@onready var choice = preload("res://QuasiEngine/Default GUI/Printers/Ink_Printer/ink_choice.tscn")

signal jump_selected
signal play_next_line

func _ready() -> void:
	load_handler()

func load_handler():
	self.modulate.a = 0.0
	

func add_choice(node: TreeNode.ChoiceNode):
	if node.lock != "":
		var expression_check = ExpressionFunctions.new()
		if expression_check.check_conditional(node.lock): #if lock conditional is TRUE
			return
	
	
	var new_choice = choice.instantiate()
	choice_stage.add_child(new_choice)
	#new_choice.a = 0.0
	new_choice.load_choice(node)
	new_choice.jump_selected.connect(_on_jump_selected)
	new_choice.choice_selected.connect(_on_choice_selected)
	new_choice.play_next_line.connect(_on_play_next_line)
	#train
	
func _on_jump_selected(goto: String):
	jump_selected.emit(goto)
	
func _on_play_next_line():
	play_next_line.emit()
	
func _on_choice_selected():
	queue_free()
