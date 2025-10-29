extends Node
class_name Utility_Functions

#merges all elements of packed string array into one string
func packed_string_array_to_str(array:PackedStringArray):
	var returnString: String = ""
	for string in array:
		returnString += string
	return returnString
	
#checks if a character('s first letter) is A-Z or a-z
func is_char_ascii(chara: String) -> bool:
	var ascii = chara.unicode_at(0)
	if(ascii >= 65 && ascii <= 90) || (ascii >= 97 && ascii <= 122):
		return true
	else:
		return false

#converts float to string represnting time. assumes float is in seconds
func float_to_time_string(time: float, secs: bool = false):
	var seconds := fmod(time, 60.0)
	var minutes := int(time / 60.00) % 60
	var hours := int(time / 3600.00)
	var time_string:String
	if secs:
		time_string = "%d:%02d:%02d" % [hours, minutes, seconds]
	else:
		time_string = "%d:%02d" % [hours, minutes]
	return time_string

#sets specific string to true or false based on string
#doesnt touch it if string is somehow neither
func str_to_bool(boolean : String, current : bool) -> bool:
	if boolean.to_lower() == "true": return true
	elif boolean.to_lower() == "false": return false
	return current

#takes takes new_string and old string, two strings that are almost same but
#new string has a new character somewhere. this func returns the index in
#new_string the new int is at

func new_char_int(new_string: String, old_string):
	
	for i in old_string.length():
		if new_string[i] != old_string[i]:
			return i	
	return old_string.length()

func is_valid_name_char(chara: String) -> bool:
	if is_char_ascii(chara):
		return true
	var ascii = chara.unicode_at(0)
	match ascii:
		39: #'
			return true
		45: #-
			return true
		_:
			return false
	

func is_char_lower(chara: String):
	var ascii = chara.unicode_at(0)
	if(ascii >= 97 && ascii <= 122):
		return true
	else:
		return false
	
func is_char_upper(chara: String):
	var ascii = chara.unicode_at(0)
	if(ascii >= 65 && ascii <= 90):
		return true
	else:
		return false
	
func is_word_upper(word: String):
	for chara in word:
		if !is_char_upper(chara):
			return false
	return true
	
func capitalize_full_string(string:String):
	var new_string = ""
	for index in string.length():
		new_string += char(string.unicode_at(index)-32)
		#var ascii = chara.unicode_at(chara)
	return new_string

func capitalize_string(string:String):
	string[0] = char(string.unicode_at(0)-32)
	return string


func to_json(save_dict: Dictionary) -> JSON:
	var json = JSON.new()
	var error = json.parse(JSON.stringify(save_dict))
	if error == OK:
		var data_recieved = json.data
		if typeof(data_recieved) == TYPE_DICTIONARY:
			print(data_recieved) # Prints the array.
		else:
			print("Unexpected data")
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", JSON.stringify(save_dict), " at line ", json.get_error_line())
	return json

#returns string value of a boolean
func bool_to_str(boolean: bool):
	if boolean: return "true"
	return "false"
