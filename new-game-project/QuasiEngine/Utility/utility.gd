extends Node

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
func float_to_time_string(time: float):
	var seconds := fmod(time, 60.0)
	var minutes := int(time / 60.00) % 60
	var hours := int(time / 3600.00)
	var time_string:String = "%d:%02d" % [hours, minutes]
	return time_string

#sets specific string to true or false based on string
#doesnt touch it if string is somehow neither
func str_to_bool(boolean : String, current : bool) -> bool:
	if boolean.to_lower() == "true": return true
	elif boolean.to_lower() == "false": return false
	return current

#returns string value of a boolean
func bool_to_str(boolean: bool):
	if boolean: return "true"
	return "false"
