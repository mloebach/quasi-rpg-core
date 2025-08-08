class_name SceneLexer
extends RefCounted

const TOKEN_TYPES := {
	COMMENT = "Comment", #token signifying line should be commented out
	COMMAND = "Command", #token signifying line is a command
	LABEL = "Label", #token signifying line is label
	#GENERIC = "GenericText", #line with no specified syntax, should be converted to @print. not actually used
	NEWLINE = "NewLine", #token representing new line
	SYMBOL = "Symbol", #token that represents value of command
	#VARIABLE = "Variable", #token that represents standin for variable. not used as far as i know
	PARAMETER = "Parameter", #token that calls parameter value of command
	BEGINBLOCK = "BeginBlock", #token signifying beginning of block for parser
	ENDBLOCK = "EndBlock" #token signifying end of block for parser
}

#reseved keywords and built in commands
const BUILT_IN_COMMANDS := {
	BACKGROUND = "back",
	CG = "cg",
	CHARACTER = "char",
	SUMMON_PRINTER = "printer",
	SUMMON_VIEWPORT = "viewport",
	PLAY_BGM = "bgm",
	PLAY_SFX = "sfx",
	PLAY_VOICE = "voice",
	MOVIE = "movie",
	PRINT_LINE = "print",
	WAIT = "wait",
	STOP_SCRIPT = "stop",
	JUMP_TO = "goto",
	SUBSCRIPT_JUMP_TO = "gosub",
	SUBSCRIPT_RETURN = "return",
	LOAD_TITLE = "title",
	LOAD_SCENE = "loadScene",
	STOP_BGM = "stopBGM",
	STOP_SFX = "stopSFX",
	STOP_VOICE = "stopVoice",
	SET_VARIABLE = "set",
	IF = "if", #not in transpiler yet
	ELSE = "else", #not in transpiler yet
	GROUP = "group", #not in transpiler yet
	WHILE = "while", #not in transpiler yet
	DELAY = "delay", #not in transpiler yet
	AWAIT = "await", #not in transpiler yet
	TRANSITION = "trans", #not in transpiler yet
	RANDOM = "random", #not in transpiler yet
	CHOICE = "choice" #not in transpiler yet
}

#var symbol_regex := RegEx.new()
#
#func _init() -> void:
	#symbol_regex.compile("[_a-zA-Z0-9]")

func read_file_content(path: String) -> String:
	if not FileAccess.file_exists(path):
		push_error("Could not find the script with path: %s" % path)
		return ""
	print("file found")
	var file := FileAccess.open(path, FileAccess.READ)
	var script := file.get_as_text()
	file.close()
	return script

#represents each component of script
class Token:
	var type: String
	var value = ""
	
	func _init(_type: String, _value) -> void:
		self.type = _type
		self.value = _value

	func _to_string() -> String:
		return "{ type=\"%s\", value=\"%s\" }" % [self.type, self.value]
		
#stores a scene file's contents and gives it specific functions
class NarrativeScript:
	var _text: String
	var _text_lines: PackedStringArray
	var _current_line := 0
	var _line_count := 0
	
	func _init(text: String) -> void:
		self._text = text
		self._text_lines = text.split("\n")
		self._line_count = _text_lines.size()
		
	func get_current_line() -> String:
		return self._text_lines[self._current_line]
		
	func iterate_to_next_line() -> String:
		#this one is different, line count is instead len(_text)
		if self._current_line +1 < _line_count:
			self._current_line += 1
			return self._text_lines[self._current_line]
		else:
			push_error("End of file encountered, there is no line to iterate to.")
			return ""
			
	func is_at_final_line() -> bool:
		return self._current_line == _text_lines.size() - 1
	
	func _to_string() -> String:
		return "text: " + _text	
	
#turns input_text into an array of token objects
func tokenize(input_text: String) -> Array[Token]:
	var tokens : Array[Token] = []
	var script := NarrativeScript.new(input_text)
	
	var indent_depth := 0
	
	while not script.is_at_final_line():
		var current_line = script.get_current_line()	
		if current_line.length() > 0:
			
			var starting_index = _first_character_index(current_line, 0)
			var line_indent_depth = indent_depth
			
			#comments wont affect indentation
			if script.get_current_line()[starting_index] != ";":
				line_indent_depth = _get_indent_level(current_line, 0, 0)
			
			#indent depth of new line versus current depth
			var depthDiff = line_indent_depth - indent_depth	
			#positive depth = we need more begin blocks
			if(depthDiff > 0):
				for indent in depthDiff:
					tokens.append(Token.new(TOKEN_TYPES.BEGINBLOCK, ""))
			elif(depthDiff < 0):
				for indent in abs(depthDiff):
					tokens.append(Token.new(TOKEN_TYPES.ENDBLOCK, ""))
			indent_depth = line_indent_depth
			
			#what type of line this is will be determined by first viable character
			var character: String = script.get_current_line()[starting_index]
			match character:
				" ", "\t":
					pass
				"@": #this is a command
					tokens.append_array(_tokenize_command(current_line.strip_edges()))
				";": #this is a comment
					tokens.append(_tokenize_comment(current_line))
				"#": #this is a label
					tokens.append(_tokenize_label(current_line))
				_: #this is generic text
					tokens.append_array(_tokenize_generic(current_line))
			
		tokens.append(Token.new(TOKEN_TYPES.NEWLINE, ""))
		script.iterate_to_next_line()
	return tokens

#gives first viable starting point of line, recusive
func _first_character_index(line: String, index: int):
	if index >= line.length():
		return 0
	if [" ","\t"].has(line[index]): #is it a tab or space?
		return _first_character_index(line, index+1)
	else:
		return index

#penalty = spaces mixed with tabs
func _get_indent_level(line: String, index: int, spaces: int):
	if index >= line.length():
		return 0
	if ["\t"].has(line[index]):
		return _get_indent_level(line, index+1, spaces)
	elif ["\t"].has(line[index]):
		push_warning("Following line mixes spaces and tabs with indentation: " + line)
		return _get_indent_level(line, index+1, spaces+1)
	else:
		return (index-spaces) #spaces shouldnt count for indent level and are ignored

func _tokenize_command(current_line: String) -> Array[Token]:
	if current_line.length() > 1:
		#var splitter_array := _split_by_quotes(current_line, 0)
		var token_array : Array[Token] = []
		var argument_list = _build_args_list(_split_by_quotes(current_line,0), 0)
		#confirm the line in question is a command, then chop off the first argument
		token_array.append(Token.new(TOKEN_TYPES.COMMAND, argument_list[0].split("@", true, 1)[1]))
		argument_list.remove_at(0)
		
		for arg in argument_list:
			if(arg.contains(":")):
				var colon_split = arg.split(":", false, 1)
				token_array.append(Token.new(TOKEN_TYPES.PARAMETER, colon_split[0]))
				if(colon_split.size() > 1):
					token_array.append(Token.new(TOKEN_TYPES.SYMBOL, colon_split[1]))
			else:
				token_array.append(Token.new(TOKEN_TYPES.SYMBOL, arg))

		return token_array
	else:
		push_warning("Line has no content after @!")
		return []

func _tokenize_generic(current_line: String):
	var token_array : Array[Token] = []
	var author_id : String = ""
	var print_text : String = ""
	
	if current_line.contains(":"):
		#get author, which is everything before the first :
		var authored_text = current_line.split(":", true, 1)
		author_id = authored_text[0].strip_edges()
		print_text = authored_text[1].strip_edges().replace("\"", "\\"+"\"")
	else:
		print_text = current_line.strip_edges().replace("\"", "\\"+"\"")
		
	var sifted_array : PackedStringArray
	#this is based off naninovel, but there's an important departure here.
	#generic text inlining is now done with "<>", with [] now used for bbcode
	#what was [<parameter] is now <+parameter>
	#within sifted array, even [0,2,4...] = outside brackets, odd [1,3,5...] = inside brackets
	var left_side : PackedStringArray = print_text.split("<")
	for cut_string in left_side:
		sifted_array.append_array(cut_string.split(">"))
		
	for index in sifted_array.size():
		#is this an odd number aka inside brackets?
		if index % 2 == 1:
			#are we dealing with a command to apply to print?
			if(sifted_array[index][0] == "+"):
				#then append it to the previous (print) command
				sifted_array[index-1] += " " + sifted_array[index].erase(0,1)
			else:
				sifted_array[index] = "@" + sifted_array[index]
		else:
			sifted_array[index] = "@print \"" + sifted_array[index] + "\""
			if author_id != "":
				sifted_array[index] += " author:" + author_id
			if index != 0:
				#make it so it won't reset after the first
				sifted_array[index] += " reset:false"
			if index < sifted_array.size()-2:
				#make it so it won't wait for input until the last one
				sifted_array[index] += " waitInput:false"
	#these should all just be generic command lines now.
	for command in sifted_array:
		if(command[0] == "@"):
			token_array.append_array(_tokenize_command(command))
			token_array.append(Token.new(TOKEN_TYPES.NEWLINE, ""))
	return token_array

func _tokenize_comment(current_line : String) -> Token:
	return Token.new(TOKEN_TYPES.COMMENT, current_line.erase(0,1))
	
func _tokenize_label(current_line : String) -> Token:
	if current_line.length() > 1:
		return Token.new(TOKEN_TYPES.LABEL, current_line.erase(0,1))
	else:
		push_error("Label has no content after #!")
		return null
	
#returns array where line is split apart by when quotes appear.
#even = outside of quotes (0,2,4...)
#odd = inside of quotes (1,3,5...)	
func _split_by_quotes(string: String, index: int) -> PackedStringArray:
	
	var stringArray: PackedStringArray
	
	if (string.length() - index) <= 0:
		stringArray.append(string)
		return stringArray
	#the last part of the check is to ignore \"
	if(string[index] == "\"" && index != 0 && string[index-1] != "\\"):
		stringArray.append(string.substr(0, index))
		stringArray.append_array(_split_by_quotes(string.substr(index+1, string.length()- index), 1))
	else:
		stringArray.append_array(_split_by_quotes(string, index+1))
	
	return stringArray
	
#separate each component by spaces and put quotes back around what surrounded them
func _build_args_list(array: PackedStringArray, index:int) -> PackedStringArray:
	var arrayToBuild :PackedStringArray
	if (index >= array.size()):
		return arrayToBuild
	arrayToBuild.append_array(array[index].split(" ", false))
	
	#put quotes back around anything after the first. odd = inside quotes
	if(index+1 < array.size()):
		arrayToBuild.append("\"" + array[index+1] + "\"")

	arrayToBuild.append_array(_build_args_list(array, index+2))
	return arrayToBuild
