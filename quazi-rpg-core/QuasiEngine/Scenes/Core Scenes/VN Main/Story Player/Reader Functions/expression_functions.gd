extends RefCounted
class_name ExpressionFunctions


var _current_node : TreeNode.CommandNode

#func check_conditional(node: TreeNode.CommandNode) -> bool:
func check_conditional(statement: String) -> bool:
	#_current_node = node
	var expression: Expression = Expression.new()
	var conditional : String = statement.trim_suffix("\"").trim_prefix("\"")
	var error = expression.parse(conditional, GlobalData.ingame_variables.keys())
	
	print("Checking conditional - " + conditional)
	
	if error != OK:
		push_error("Expression parse error: " + expression.get_error_text())
		push_error("In other words, something is up with: " + conditional)
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

func set_variable(expression: String) -> void:
	#current_node = node
	var command_list = expression.split(";", true)
	for command in command_list:
		set_variable_step(command)
		
func set_variable_step(command: String) -> void:
	var expression_to_set : String
	var variable_to_change : String
	
	#turn the string into something legible
	if(command.split("=",true,1).size() < 2): #if there's not am equal sign...
		match command.right(2): #how does it end?
			#assume ++ and -- are always in format of var++ or var--
			"++":
				variable_to_change = command.left(-2)
				expression_to_set = variable_to_change + "+1"
			"--":
				variable_to_change = command.left(-2)
				expression_to_set = variable_to_change + "-1"
			_:
				push_error("Set variable given strange instructions with ++ or --: " + command)
	else:
		var assignment_commands = command.split("=",true,1)
		
		#account for bitwise
		if(
			[">>","<<","**"].has(assignment_commands[0].right(2))
			#@set variable<<=3
		):
			variable_to_change = assignment_commands[0].left(-2)
			expression_to_set = assignment_commands[0] + assignment_commands[1].replace(' ','')
		elif(
			["+","-","/","*","%","&","|","^"].has(assignment_commands[0].right(1))
			#@set variable+=3
		):
			variable_to_change = assignment_commands[0].left(-1)
			expression_to_set = assignment_commands[0]+ assignment_commands[1].replace(' ','')
		else:
			#set variable="Big bag with one cookie in it"
			variable_to_change = assignment_commands[0]
			expression_to_set = assignment_commands[1].replace(' ','')
			
	var expression: Expression = Expression.new()
	var error = expression.parse(expression_to_set, GlobalData.ingame_variables.keys())
	if error != OK:
		push_error("Expression " + command + " parse error: " + expression.get_error_text())
		push_error("Hey! There is actuallly a variable named " + expression_to_set + "in ingame variables, right?")
	var result = expression.execute(GlobalData.ingame_variables.values(), self)
	if expression.has_execute_failed():
		push_error("Setter (" + expression_to_set + ") makes no sense!" )
	else: #then set the value
		if(
			!GlobalData.ingame_variables.has(variable_to_change) ||
			typeof(GlobalData.ingame_variables[variable_to_change]) == typeof(result)
		):
			GlobalData.ingame_variables[variable_to_change] = result
		else:
			push_warning("Variable %s of type %s can't be cast into %s" %
				[
					variable_to_change,
					type_string(typeof(GlobalData.ingame_variables[variable_to_change])),
					type_string(typeof(result))
				]
			)
