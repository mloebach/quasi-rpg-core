class_name TreeNode
extends RefCounted

#Command nodes for SceneTranspiler

#most basic node object
class BaseNode:
	var next: int
	func _init(_next: int) -> void:
		self.next = _next

#node which represents labelnode
class LabelNode:
	extends BaseNode
	var label: String
	
	func _init(_next: int, _label : String) -> void:
		super(_next)
		self.label = _label
		
	func _to_string() -> String:
		return "{next:%s, label:%s}" % [next, label]

#COMMAND NODES
class CommandNode:
	extends BaseNode
	
	var command: String
	var args := []
	
	var wait: String
	var conditional: String = ""
	
	func _init(_next: int) -> void:
		super(_next)

#nodes that have a time element
class AsyncNode:
	extends CommandNode
	
	var time: String

	func _init(_next: int) -> void:
		super(_next)
		wait = Util.bool_to_str(GlobalData.wait_by_default)

#commands that have an audio element but cant loop
class QuickAudioNode:
	extends AsyncNode
	
	var audioPath: String
	var volume: String
	var group: String
	
	func _init(_next: int) -> void:
		super(_next)


#commands for audio that persists like sfx and bgm
class AudioNode:
	extends QuickAudioNode
	
	var loop: String
	var fade: String
	
	func _init(_next: int) -> void:
		super(_next)

#command which has option for something to move
class MovableNode:
	extends AsyncNode

	var easing: String
	var lazy: String
	
	func _init(_next: int) -> void:
		super(_next)
	
#commands which deal with text created by the printer
class PrinterTextNode:
	extends CommandNode
	var printer: String
	
	func _init(_next: int) -> void:
		super(_next)
	
	
#print command
class PrintNode:
	extends PrinterTextNode
	
	var text: String
	var author: String
	var authorOverride: String
	var speed: String
	var reset: String
	var default: String
	var waitInput: String
	var append: String
	var fadeTime: String
	var cipher: String
	
	func _init(_next: int, _text: String, _author: String = "") -> void:
		super(_next)
		self.text = _text
		self.author = _author
		
	
	func _to_string() -> String:
		return "{next:%s, text:%s, author:%s, waitInput:%s, reset:%s}" % [next, text, author, waitInput, reset]

		
#command which manages an actor, such as a sprite, bg, or cg.
class ActorNode:
	extends MovableNode
	
	var id: String
	var appearance: String
	var pose: String
	var transition: String
	var params: String
	var dissolve: String
	var visible: String
	var pos: String
	var position: String
	var z: String
	var rotation: String
	var scale: String
	var tint: String
	var opacity: String
	
	var viewport: String
	
	func _init(_next: int) -> void:
		super(_next)
		
#command that changes displayed background, with optional transition animation
class BGNode:
	extends ActorNode
	
	func _init(_next: int, _background: String, _transition: String = "default") -> void:
		super(_next)
		self.id = "MainBackground"
		self.appearance = _background
		self.transition = _transition

	func _to_string() -> String:
		return "{next:%s, args:%s, bg:%s, transition:%s, tint:%s}" % [next, args, appearance, transition, tint]
		
#command that changes displayed cg. technically the same as bg for now
class CGNode:
	extends ActorNode
	
	func _init(_next: int, _background: String, _transition: String = "default") -> void:
		super(_next)
		self.id = "MainCG"
		self.appearance = _background
		self.transition = _transition

	func _to_string() -> String:
		return "{next:%s, args:%s, cg:%s, transition:%s, tint:%s}" % [next, args, appearance, transition, tint]
		
		
#command which summons character
class CharNode:
	extends ActorNode
	
	var look: String
	var avatar: String
	
	func _init(_next: int, _id : String) -> void:
		super(_next)
		self.id = _id
	
	func _set_appearance(_id: String):
		self.appearance = _id
		
	func _to_string() -> String:
		return "{next:%s, id:%s, appearance:%s, pos:%s}" % [next, id, appearance, pos]


#command which summons printer. not to be confused with printertext
class PrinterNode:
	extends ActorNode
	
	var default: String
	var hideOther: String

		
	func _init(_next: int, _id: String, _appearance: String = "Default") -> void:
		super(_next)
		self.id = _id
		#change appearances to pose once this can recognize which is which
		self.appearance = _appearance
	
	func _to_string() -> String:
		return "{next:%s, id:%s, appearance:%s, pos:%s}" % [next, id, appearance, pos]
		
		
#command which summons viewport
class ViewportNode:
	extends ActorNode
	
	func _init(_next:int, _id: String, _appearance: String = "Default") -> void:
		super(_next)
		self.id = _id
		self.appearance = _appearance

	func _to_string() -> String:
		return "{next:%s, id:%s, appearance:%s, pos:%s}" % [next, id, appearance, pos]

#command which plays voice
class VoiceNode:
	extends QuickAudioNode
	
	var authorID : String
	
	func _init(_next: int, sfxPath: String):
		super(_next)
		self.audioPath = sfxPath
	
	func _to_string() -> String:
		return "{next:%s, path:%s, volume:%s, author:%s}" % [next, audioPath, volume, authorID]
		
		
#command which plays sfx
class SFXNode:
	extends AudioNode
		
	func _init(_next: int, sfxPath: String):
		super(_next)
		self.audioPath = sfxPath
		
	func _to_string() -> String:
		return "{next:%s, path:%s, volume:%s, loop:%s}" % [next, audioPath, volume, loop]
		
#command which plays bgm
class BGMNode:
	extends AudioNode
	
	var intro : String
	var clip: String
	
	func _init(_next: int, _bgmPath: String, _clip: String = ""):
		super(_next)
		self.audioPath = _bgmPath
		self.clip = _clip
		
	func _to_string() -> String:
		return "{next:%s, path:%s, volume:%s, loop:%s}" % [next, audioPath, volume, loop]
		
#command which plays movie file
class MovieNode:
	extends CommandNode
		
	var movieName: String
	var time: String
	var block: String
	
	func _init(_next: int, _movieName: String):
		super(_next)
		self.movieName = _movieName
		
	func _to_string() -> String:
		return "{next:%s, movieName:%s}" % [next, movieName]
		
class JumpNode:
	extends CommandNode
	
	var path : String
	
	func _init(_next: int, _path: String) -> void:
		super(_next)
		self.path = _path
	
	func _to_string() -> String:
		return "{next:%s, path:%s}" % [next, path]
		
		
#command which makes game yield for a specific amt of time
class WaitNode:
	extends CommandNode
	
	#var waitMode : String
	var inputMode := "noInput"
	var waitTime := "0.0"
	
	func _init(_next: int, _waitMode: String):
		super(_next)
		if _waitMode != "" && _waitMode[0] == "i":
			inputMode = "input"
			_waitMode = _waitMode.erase(0)
		#print(str(float(_waitMode)))
		waitTime = _waitMode
		if(float(waitTime)) > 0:
			inputMode = "waitOrInput"

	func _to_string() -> String:
		return "{next:%s, waitTime:%s, inputMode:%s}" % [next, waitTime, inputMode]
		
		
#command which sets variables
class SetNode:
	extends CommandNode
	
	var expression : String
	
	func _init(_next:int, _expression:String):
		super(_next)
		self.expression = _expression
		
	func _to_string() -> String:
		return "{next:%s, expression%s}" % [next, expression]
		
		
#command which swaps out the vn scene for a different one
class SceneSwapNode:
	extends CommandNode
	
	var new_scene : String
	var additive: String
	
	func _init(_next:int, _new_scene:String):
		super(_next)
		self.new_scene= _new_scene
		
	func _to_string() -> String:
		return "{next:%s, expression%s}" % [next, new_scene]

#class with an associated indent
#might not be necessary if group has no arguments
#class IndentNode:
