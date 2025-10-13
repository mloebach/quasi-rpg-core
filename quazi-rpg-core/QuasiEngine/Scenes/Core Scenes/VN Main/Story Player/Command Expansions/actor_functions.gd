extends Node
class_name ActorFunctions
	
var player: StoryPlayer
	#signal command_done
	
func _init(_player: StoryPlayer):
	self.player = _player


func create_background_asset(node: TreeNode.BGNode):
	pass
