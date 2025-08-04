extends Node

#merges all elements of packed string array into one string
func packed_string_array_to_str(array:PackedStringArray):
	var returnString: String = ""
	for string in array:
		returnString += string
	return returnString
	
#checks if a character('s first letter) is A-Z or a-z
func is_char_ascii(char: String) -> bool:
	var ascii = char.unicode_at(0)
	if(ascii >= 65 && ascii <= 90) || (ascii >= 97 && ascii <= 122):
		return true
	else:
		return false

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
