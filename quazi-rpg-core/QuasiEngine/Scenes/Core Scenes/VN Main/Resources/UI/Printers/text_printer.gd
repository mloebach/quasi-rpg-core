extends Control
class_name TextPrinter

#debug function which sets all wait times to zero to check if a script works
#@export var sweep : bool = false

const link_color = Color.CORNFLOWER_BLUE

@export var secPerChar : float = 0.04
@export var minimum_print_time : float = 0.7
var printer_type: String
var _printer_traits: PrinterResource
var _wait_input: bool 
var _awaiting_input := false
var _loading_text := false
var _input_timer := 0.0
var _early_text := false
#var _next_node : int
var _current_node : TreeNode.PrintNode
#var _auto_timer := 0.0

var choice_queue: Array[TreeNode.ChoiceNode]
var choice_handler: ChoiceHandler

signal command_done
signal input_pressed
signal end_print_line
signal jump_selected
signal gosub_selected

#var skip_author := false

func initalize_printer(printer_data: PrinterResource) -> void:
	_printer_traits = printer_data
	

func set_printer_text(node: TreeNode.PrintNode):
	#print("Updating text! " + node.text)

	#swaps "text" for \"text\"
	_current_node = node
	
	
	
	var node_text = node.text
	
	node_text = format_in_tags(node_text)
	
	node_text = node_text.trim_suffix("\"").trim_prefix("\"").replace("\\"+"\"", "\"")
	
	#add cipher here
	if(node.args.has("cipher")):
		node_text = Util.cipher_text(node_text, node.cipher)
		
	if(node.args.has("waitInput")):
		_wait_input = Util.str_to_bool(node.waitInput, _printer_traits.autoWait)
	else:
		_wait_input = _printer_traits.autoWait
	
	var visible_index = 0
	
	
	
	if Util.str_to_bool(node.reset, _printer_traits.autoReset):
		#print("reseting text!")
		clear_text()
	else:
		visible_index = get_text_box().length()
		
	get_text_box().visible_characters = visible_index
	var author_string = ""
	var authors = node.author.split(",",false)
	if(node.args.has("authorOverride")):
		author_string = node.authorOverride
	elif(node.args.has("author")):
		author_string = node.author
		
	
	
	
	if(!get_author_text_box() == null):
		get_author_text_box().clear()
		
		if(GlobalData.characters.has(author_string)):
			get_author_text_box().push_color(GlobalData.characters[author_string].character_color)
			get_author_text_box().push_hint(GlobalData.characters[author_string].hint)
			get_author_text_box().append_text(
				"[url=" + author_string + "]" +
				GlobalData.characters[author_string].display_name
				+ "[/url]"
			)
			get_author_text_box().pop()
			get_author_text_box().pop()
		else:
			get_author_text_box().append_text(author_string)
	
	get_text_box().append_text(node_text)
	get_text_box().text = node_text
	
	#scroll_to_bottom()
	
	GlobalData.tts_speak(node_text)
	
	var speed_multiplier = 1.0
	if(node.args.has("speed")):
		speed_multiplier = 1.0 / float(node.speed)
	if(GlobalData.game_db.sweep): #debug function which eliminated waits
		speed_multiplier = 0.0
	var char_multiplier = 1.0

	
	#if wait=false, send command done command now:
	if(!Util.str_to_bool(node.wait, true)):
		await get_tree().create_timer(0.0).timeout
		command_done.emit()
		end_print_line.emit()
		
	scroll_to_bottom()
	#text reveal. skip if append is in arguments
	if(node.args.has("append") && Util.str_to_bool(node.append, false)):
		get_text_box().visible_characters = -1
	else:
		var index = 0
		_loading_text = true
		while index < (get_text_box().get_parsed_text().length() - visible_index) && !_early_text:
		
		#for index in (get_text_box().get_parsed_text().length() - visible_index):
			get_text_box().visible_characters = visible_index+index+1
			#wait time is slightly longer for line ends and a little longer for dividing grammar
			if( visible_index+index < get_text_box().get_parsed_text().length() &&
				[".","!","?"].has(get_text_box().get_parsed_text()[visible_index+index]) &&
				
				(
					#does the next index NOT have one of the characters?
					visible_index + index + 1 < get_text_box().get_parsed_text().length() &&
					![".","!","?"].has(get_text_box().get_parsed_text()[visible_index+index+1])	
				) 
			):
				char_multiplier = 7.0
			elif( visible_index+index < get_text_box().get_parsed_text().length() &&
				[";",","].has(get_text_box().get_parsed_text()[visible_index+index]) &&
				(
					visible_index + index + 1 < get_text_box().get_parsed_text().length() &&
					![";",","].has(get_text_box().get_parsed_text()[visible_index+index+1])	
				) 
			): 
				char_multiplier = 3.0
			else:
				char_multiplier = 1.0
			#if Util.str_to_bool(node.wait, true):
			
			await get_tree().create_timer(secPerChar*speed_multiplier*char_multiplier).timeout
			if(!GlobalData.printer_paused):
				index+=1
	
	
	if(Util.str_to_bool(node.wait, true)):
		command_done.emit()
		
	_loading_text = false
	_early_text = false
	#GlobalData.get_screenshot("autosave")
	#wait for user input
	if _wait_input && Util.str_to_bool(node.wait, true):
		#await get_tree().create_timer(0.3).timeout
		#text scroll is done
		#get_text_box().visible_characters = -1
		#get_text_box().append_text(" ")
		#figure out what to do with text marker when its time
		#get_text_box().add_image(textDoneMarker, 28, 28, Color.WHITE, INLINE_ALIGNMENT_BOTTOM)
		#_awaiting_input = true
		if(!GlobalData.game_db.sweep):
			await get_tree().create_timer(0.3).timeout
		await_input()
		await input_pressed
		

		#textboxText.clear()
		#textboxText.append_text(currentText)
	#print("sending end_print signal...")
	end_line_procedure()
	end_print_line.emit()

func create_choices_on_printer():
	#if choice_queue.size() > 0:
		#if choice_handler == null: #create choice handler if there isn't one
			#if self is InkTextPrinter:
				#choice_handler = create_choice_handler()
				#
		#for choice in choice_queue:
			#choice_handler.add_choice(choice)
		#choice_queue.clear()
		#choice_handler.jump_selected.connect(_on_jump_selected)
	pass

func format_in_tags(text: String):
	var new_text := ""
	var sample_rich_text = RichTextLabel.new()
	#var new_text_array : Array[String]
	var starting_index = 0
	var counter = 0
	var parsed_wc = 0
	for letter in text.length()-1:
		if (
			(text[letter] == "(" && text[letter+1] == "@") || text.substr(letter, 3) == "(!@"
			 && counter % 2 == 0
			):
			sample_rich_text.text = text.substr(starting_index, letter-starting_index)
			parsed_wc += sample_rich_text.get_parsed_text().length()
			new_text += sample_rich_text.text
			#sample_rich_text.text = new_text
			starting_index = letter
			counter += 1
		if text[letter] == ")" && (counter % 2 == 1):
			
			var original_text = text.substr(starting_index, letter-starting_index)
			#sample_rich_text.text += "\""
			#var parsed_text = sample_rich_text.get_parsed_text()
			var link_text = color_print_text(original_text, parsed_wc)
			new_text += link_text
			#sample_rich_text.text = link_text
			var display_text = original_text.split(",",true,1)
			parsed_wc += display_text[display_text.size()-1].length()
			
			#sample_rich_text.text = new_text
			starting_index = letter+1
			counter += 1
	new_text += text.substr(starting_index, text.length()-starting_index)
	pass
	
	return new_text
	
func color_print_text(text: String, index: int):
	var new_text = ""
	var _color = link_color.to_html()
	
	if text.left(2) == "(@":
		new_text = text.right(-2)
	elif text.left(3) == "(!@":
		new_text = text.right(-3)
		var hover = new_text.split(",", true, 1)
		#var icon = ""
		if hover[1].contains("@"):
			var hover_array = hover[1].split("@", true, 1)
			return ("[url={\"hover\": \"%s\", \"pos\": %s, \"h_icon\": \"%s\"}][color=%s][b]%s[/b][/color][/url]" % [hover_array[0], index, hover_array[1], _color, hover[0]])
		return ("[url={\"hover\": \"%s\", \"pos\": %s, \"h_icon\": \"%s\"}][color=%s][b]%s[/b][/color][/url]" % [hover[1], index, "", _color, hover[0]])
		
	var link = new_text.split(",", true, 1)
	var display_text = link[link.size()-1]
	
	if GlobalData.keyword_links.has(link[0].to_lower()):
		_color = GlobalData.keyword_links[link[0].to_lower()].color.to_html()
	#special case for zenith / z_name
	if link[0].to_lower() == "z_name":
		#link[0] = GlobalData.player_save.player_name
		_color = GlobalData.player_save.z_color
		if link.size() < 2:
			display_text = "[" +GlobalData.player_save.player_name +"]"
	#return later index, 0 if no alt specified and 1 if specified
	return ("[url={\"wiki\": \"%s\", \"pos\": %s}][color=%s][b]%s[/b][/color][/url]" % [link[0], index, _color, display_text])

func _on_jump_selected(goto: String):
	jump_selected.emit(goto)
	
func _on_gosub_selected(gosub: String):
	print("Gosub selected!")
	gosub_selected.emit(gosub, _current_node.next)

func _process(delta: float) -> void:
	
	#print("process loop")
	
	if(GlobalData.game_db.sweep):
		minimum_print_time = 0.0
	
	if(_loading_text):
		_input_timer += delta
		#print("Waiting for input: " + str(_input_timer))
		if((Input.is_action_just_pressed("advance_text") || GlobalData.game_db.sweep)&& _input_timer > minimum_print_time):
			#_early_text = true
			#_input_timer = 0
			#get_text_box().visible_characters = -1
			if(!GlobalData.printer_paused):
				early_input()
			
	
	if(Input.is_action_just_pressed("advance_text") && _awaiting_input && !GlobalData.printer_paused):
		print("input recieved! advancing text")
		advance_text()
		#_awaiting_input = false
		#input_pressed.emit()
		
	if(_awaiting_input && GlobalData.auto_printer_on && !GlobalData.printer_paused):
		GlobalData.auto_timer += delta
		print("AUTO TIMER: " + str(GlobalData.auto_timer))
	if(GlobalData.auto_timer > GlobalData.auto_timer_wait ||GlobalData.game_db.sweep):
		#auto timer trigger
		if(!GlobalData.printer_paused):
			advance_text()

func early_input():
	_early_text = true
	_input_timer = 0
	get_text_box().visible_characters = -1
	
func advance_text():
	_awaiting_input = false
	GlobalData.auto_timer = 0.0
	GlobalData.player_save.main_save.script_index = _current_node.next
	#dont create autosaves on skip_new_debug function
	if !GlobalData.game_db.skip_to_new:
		GlobalData.create_autosave()
	input_pressed.emit()

#func create_autosave():
	#
	#GlobalData.player_save.main_save.date_saved = Time.get_datetime_string_from_system(false, true)
	#var auto = FileAccess.open(GlobalData.player_save.auto_save_json, FileAccess.WRITE)
	#
	#auto.store_line(JSON.stringify(GlobalData.player_save.main_save.main_to_json().data))
	#auto.close()

func clear_text():
	#this is a function for your children to work with
	pass
	
func end_line_procedure():
	#this is a function for your children to work with
	pass
	
func scroll_to_bottom():
	#this is a function for your children to work with
	pass
	
func create_choice_handler():
	pass
	
func await_input() -> void:
	#await get_tree().create_timer(0.3).timeout
	get_text_box().visible_characters = -1
	print("awaiting input!")
	_awaiting_input = true
	
func get_text_box() -> RichTextLabel:
	#this is a function for your children to work with
	return null

func get_author_text_box() -> RichTextLabel:
	#this is a function for your children to work with
	return null
