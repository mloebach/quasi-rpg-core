extends StoryPlayer
class_name ExpressionFunctions


var _current_node : TreeNode.CommandNode

func check_conditional(node: TreeNode.CommandNode) -> bool:
	_current_node = node
	var expression: Expression = Expression.new()
	var conditional : String = node.conditional.trim_suffix("\"").trim_prefix("\"")
	var error = expression.parse(conditional, GlobalData.ingame_variables.keys())
	
	if error != OK:
		push_error("Expression parse error: " + expression.get_error_text())
		return false
		
	var result : bool = expression.execute( GlobalData.ingame_variables.values(), self)
	if expression.has_execute_failed():
		push_error("Conditional (" + conditional + ") makes no ham sense!" )
		return false
	else:	
		print("conditional " + conditional + " is " + str(result))
		return result

func display_variable(conditional: String, node: TreeNode.CommandNode) -> String:


	_current_node = node
	var expression: Expression = Expression.new()
	
	var result
	if (
		GlobalData.ingame_variables.has(conditional) &&
		GlobalData.ingame_variables[conditional] is PackedStringArray
		):
		var newConditional = Util.packed_string_array_to_str(GlobalData.ingame_variables[conditional])
		return newConditional
	else:
		var error = expression.parse(conditional, GlobalData.ingame_variables.keys())
		if error != OK:
			push_error("Expression parse error: " + expression.get_error_text())
			return conditional
		result = expression.execute(GlobalData.ingame_variables.values(), self)
	
	if expression.has_execute_failed():
		push_error("Variable (" + conditional + ") not present in database!" )
		return ""
	else:	
		#print("conditional " + node.conditional + " is " + str(result))
		return str(result)
