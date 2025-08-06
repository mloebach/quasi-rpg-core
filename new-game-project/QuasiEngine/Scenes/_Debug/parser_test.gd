extends Node2D

@export_file("*.story") var example_script: String

#turn text in file into array of tokens
var lexer := SceneLexer.new()
#turn array of tokens into branching tree of tokens
var parser := SceneParser.new()
#turn tree of tokens into branching tree of command nodes
#var transpiler := SceneTranspiler.new()


func _ready() -> void:
	var text := lexer.read_file_content(example_script)
	#print(text)
	var tokens: Array = lexer.tokenize(text)
	print("Tokens: " + str(tokens))
	var tree: SceneParser.SyntaxTree = parser.parse(tokens)
	print(tree.values)
	#var script: SceneTranspiler.StoryTree = transpiler.transpile(tree,0)
