class_name SceneParser
extends RefCounted

#names of the possible expressions supposed by parser
const EXPRESSION_TYPES := {
	COMMAND = SceneLexer.TOKEN_TYPES.COMMAND,
	LABEL = SceneLexer.TOKEN_TYPES.LABEL,
	IF = SceneLexer.BUILT_IN_COMMANDS.IF,
	ELSE = SceneLexer.BUILT_IN_COMMANDS.ELSE,
	ELIF = SceneLexer.BUILT_IN_COMMANDS.ELIF,
	GROUP = SceneLexer.BUILT_IN_COMMANDS.GROUP
}

class SyntaxTree:
	var values : Array = []
	
	#this starts at -1 so it can index right
	var current_index := -1
	
	func append_expression(expression: BaseExpression) -> void:
		values.append(expression)
		
	func move_to_next_expression() -> BaseExpression:
		if not is_at_end():
			current_index +=1
			return self.values[current_index]
		return null
		
	func peek_at_next_expression() -> BaseExpression:
		if not is_at_end():
			return self.values[current_index + 1]
		return null
		
	func is_at_end() -> bool:
		return current_index == len(values) - 1

#basic expression
class BaseExpression:
	var type: String
	var value
	
	func _init(_type: String, _value) -> void:
		self.type = _type
		self.value = _value

	func _to_string() -> String:
		return "{type: %s, val: %s}" % [type, value]
		
#expression that has arguments
class FunctionExpression:
	extends BaseExpression
	var arguments: Array
	
	func _init(_type: String, _value: String, _arguments: Array) -> void:
		super(_type, _value)
		self.arguments = _arguments
		
	func _to_string() -> String:
		return "{type: %s, val: %s, args: %s (size: %s)}" % [type, value, "".join(arguments), arguments.size()]

#expression which hinges on a boolean to active
class BlockFunctionExpression:
	extends BaseExpression
	
	var block: Array
	
	func _init(_type: String, _value, _block: Array) -> void:
		super(_type, _value)
		self.block = _block
		
	func _to_string() -> String:
		return "{type: %s, val: %s, block: %s}" % [type, value, "".join(block)]

#tree of conditional expressions
class ConditionalTreeExpression:
	extends BaseExpression
	var if_block: BlockFunctionExpression
	var else_block: Array
	var elif_block: BlockFunctionExpression

	func _init(
		_type: String,
		_value: String,
		_if_block: BlockFunctionExpression,
		_elif_block:  BlockFunctionExpression,
		_else_block: Array
	) -> void:
		super(_type, _value)
		self.if_block = _if_block
		self.elif_block = _elif_block
		self.else_block = _else_block


class Parser:
	var current_index = -1
	var _tokens := []
	var _length := 0
	
	func _init(tokens: Array) -> void:
		self._tokens = tokens
		self._length = len(self._tokens)
		
	func move_to_next_token() -> SceneLexer.Token:
		self.current_index += 1
		return self._tokens[self.current_index]
	
	func is_at_end_of_list() -> bool:
		return current_index == _length - 1
		
	func peek_at_next_token() -> SceneLexer.Token:
		if not is_at_end_of_list():
			return self._tokens[self.current_index +1]
		else:
			return SceneLexer.Token.new("","")
			
	func find_expressions(stop_at_type: String) -> Array:
		var arguments := []
		while not self.is_at_end_of_list() and self.peek_at_next_token().type != stop_at_type:
			var expression := self.parse_next_token()
			if expression:
				arguments.append(expression)
		return arguments
		
	#parse next token ad return correct expression to the tree
	func parse_next_token() -> BaseExpression:
		var current_token := self.move_to_next_token()
		if current_token.type == SceneLexer.TOKEN_TYPES.COMMAND: #command with arguments
			
			
				
			
			#find everything after until you hit newline
			var arguments := self.find_expressions(SceneLexer.TOKEN_TYPES.NEWLINE)
			#if self.peek_at_next_token().type = 
			return FunctionExpression.new(current_token.type, current_token.value, arguments)
		elif ( #no frills nothing fancy Base Expression
			current_token.type in [
				#comments don't matter anymore since they're junk
				#generic text doesnt exist anymore by time lexer is done
				#newline is there to let commands know when to stop, otherwise junk
				SceneLexer.TOKEN_TYPES.LABEL, #basic, all label info is in its token
				SceneLexer.TOKEN_TYPES.SYMBOL, #always extension of command
				SceneLexer.TOKEN_TYPES.PARAMETER#always extension of command
				#SceneLexer.TOKEN_TYPES.GENERIC #this doesn
			]
		):
			return BaseExpression.new(current_token.type, current_token.value)
		else:
			return null
			
#takes in list of tokens and returns a syntax tree
func parse(tokens: Array) -> SyntaxTree:
	var parser = Parser.new(tokens)
	var tree := SyntaxTree.new()
	
	while not parser.is_at_end_of_list():
		var expression: BaseExpression = parser.parse_next_token()
		
		if expression:
			tree.append_expression(expression)
	
	return tree
