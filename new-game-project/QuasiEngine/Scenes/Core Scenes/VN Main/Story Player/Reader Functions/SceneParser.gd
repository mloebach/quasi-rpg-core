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
	extends FunctionExpression
	
	var block: Array
	
	func _init(_type: String, _value, _arguments:Array, _block: Array) -> void:
		super(_type, _value, _arguments)
		self.block = _block
		
	func _to_string() -> String:
		return "{type: %s, val: %s, block: %s}" % [type, value, "".join(block)]

#tree of conditional expressions
class ConditionalTreeExpression:
	extends FunctionExpression
	var if_block: BlockFunctionExpression
	var else_block: Array

	func _init(
		_type: String,
		_value: String,
		_arguments:Array,
		_if_block: BlockFunctionExpression,
		_else_block: Array
	) -> void:
		super(_type, _value, _arguments)
		self.if_block = _if_block
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
		
	## Returns expressions from an indented block
	func parse_indented_block() -> Array:
		var block_content := []

		# Stack starts with 1 because we skip the first BEGIN_BLOCK token
		var indent_stack := 1

		print("Peek-" + peek_at_next_token().type)
		if self.peek_at_next_token().type == SceneLexer.TOKEN_TYPES.BEGINBLOCK:
			print("Skipping beginning block.")
			self.move_to_next_token()

		while not self.is_at_end_of_list():
			var expression := self.parse_next_token()
			

			if expression == null:
				continue

			print(expression.type + "/" + expression.value + " - " + str(indent_stack))

			if expression.type == SceneLexer.TOKEN_TYPES.BEGINBLOCK:
				indent_stack += 1

				# Recursively parse the block
				block_content.append(parse_indented_block())
			elif expression.type == SceneLexer.TOKEN_TYPES.ENDBLOCK:
				indent_stack -= 1

				if indent_stack == 0:
					print("Exit block.")
					return block_content
				else:
					break
			else:
				block_content.append(expression)
		print("Block null.")
		return []
		
	#parse next token ad return correct expression to the tree
	func parse_next_token() -> BaseExpression:
		var current_token := self.move_to_next_token()
		if current_token.type == SceneLexer.TOKEN_TYPES.COMMAND: #command with arguments
			
			
				
			
			#find everything after until you hit newline
			var arguments := self.find_expressions(SceneLexer.TOKEN_TYPES.NEWLINE)
			#commands that have a group of nested commands theyre assigned to
			if (
				current_token.value == SceneLexer.BUILT_IN_COMMANDS.GROUP ||
				current_token.value == SceneLexer.BUILT_IN_COMMANDS.WHILE ||
				current_token.value == SceneLexer.BUILT_IN_COMMANDS.DELAY ||
				current_token.value == SceneLexer.BUILT_IN_COMMANDS.AWAIT ||
				current_token.value == SceneLexer.BUILT_IN_COMMANDS.TRANSITION ||
				current_token.value == SceneLexer.BUILT_IN_COMMANDS.RANDOM ||
				current_token.value == SceneLexer.BUILT_IN_COMMANDS.CHOICE
			):
				print("Creating group at: " + current_token.type + "-" + current_token.value)
				#starts on newline otherwise. should it automove?
				if(self.peek_at_next_token().type == SceneLexer.TOKEN_TYPES.NEWLINE):
					self.move_to_next_token()
				return BlockFunctionExpression.new(current_token.type, current_token.value, arguments, parse_indented_block())
			elif (
				current_token.value == SceneLexer.BUILT_IN_COMMANDS.IF
			):
				print("Creating if group at: " + current_token.type + "-" + current_token.value)
				if(self.peek_at_next_token().type == SceneLexer.TOKEN_TYPES.NEWLINE):
					self.move_to_next_token()
				var if_block = BlockFunctionExpression.new(current_token.type, current_token.value, arguments, parse_indented_block())
				if(self.peek_at_next_token().type == SceneLexer.TOKEN_TYPES.ENDBLOCK):
					self.move_to_next_token()
				
				var else_blocks = []
				
				print("after if line its: " + peek_at_next_token().type)
				while peek_at_next_token().value == SceneLexer.BUILT_IN_COMMANDS.ELSE:
					
					#you dont want to include command
					self.move_to_next_token()
					
					
					var else_arguments := self.find_expressions(SceneLexer.TOKEN_TYPES.NEWLINE)
					if(self.peek_at_next_token().type == SceneLexer.TOKEN_TYPES.NEWLINE):
						self.move_to_next_token()
					
					else_blocks.append(
						BlockFunctionExpression.new(current_token.type, SceneLexer.BUILT_IN_COMMANDS.ELSE, else_arguments, parse_indented_block())
					)
				
				print("done with if/else")
				return ConditionalTreeExpression.new(current_token.type, current_token.value, arguments, if_block, else_blocks)
				
			return FunctionExpression.new(current_token.type, current_token.value, arguments)
		elif ( #no frills nothing fancy Base Expression
			current_token.type in [
				#comments don't matter anymore since they're junk
				#generic text doesnt exist anymore by time lexer is done
				#newline is there to let commands know when to stop, otherwise junk
				SceneLexer.TOKEN_TYPES.LABEL, #basic, all label info is in its token
				SceneLexer.TOKEN_TYPES.SYMBOL, #always extension of command
				SceneLexer.TOKEN_TYPES.PARAMETER,#always extension of command
				SceneLexer.TOKEN_TYPES.BEGINBLOCK,
				SceneLexer.TOKEN_TYPES.ENDBLOCK
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
