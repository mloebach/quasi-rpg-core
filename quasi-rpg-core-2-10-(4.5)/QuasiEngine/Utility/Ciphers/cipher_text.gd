extends Utility_Functions

var ciphers: Array[Cipher] = [
	preload("res://QuasiEngine/Utility/Ciphers/Cipher_Resources/high_aquolion.tres"),
	preload("res://QuasiEngine/Utility/Ciphers/Cipher_Resources/k_cipher.tres")
]

func get_cipher(name: String):
	for cipher in ciphers:
		if cipher.name == name:
			return cipher
	push_error("No ciphers with name " + name + " found!")
	return null

func cipher_text(text: String, cipher: String):
	
	var _cipher_functions = Cipher_Functions.new()
	var expression: Expression = Expression.new()
	
	var error = expression.parse(get_cipher(cipher).expression, ["text"]+get_cipher(cipher).variables.keys())
	
	if error != OK:
		push_error("Expression parse error: " + expression.get_error_text())
		return false
	
	var result : String = expression.execute([text]+get_cipher(cipher).variables.values(), _cipher_functions)
	
	if expression.has_execute_failed():
		push_error("Cipher (" + cipher + ") makes no ham sense!" )
		return false
	else:	
		print("ciphered " + text + " is " + str(result))
		return result

func is_char_ascii(char: String) -> bool:
	var ascii = char.unicode_at(0)
	if(ascii >= 65 && ascii <= 90) || (ascii >= 97 && ascii <= 122):
		return true
	else:
		return false

class Cipher_Functions:
	
	func k_cipher(text: String, letterSymbol: String):
		var newText: String
		var ignore: bool = false
		for letter in text:
			var unicode = letter.unicode_at(0)
			#print("letter " + letter + " unicode " + str(unicode))
			if letter == "[":
				ignore = true
			
			if !ignore && Util.is_char_ascii(letter):
				newText+= letterSymbol
			else:
				newText+= letter
				
			if letter == "]":
				ignore = false
		return newText

	func aquolion(text: String):
		var newText: String
		
		var siftedArray : PackedStringArray
		var leftSide : PackedStringArray = text.split("[")
		for cutString in leftSide:
			siftedArray.append_array(cutString.split("]"))
		for index in siftedArray.size():
			
			#ignore everythingside brackets
			if index % 2 == 0:
				var words = siftedArray[index].split(" ", false)
				for word in words:
					newText+= aquolion_filter(word)
					if(word.length()>0):
						newText += " "
				if (
						!should_end_with_space(siftedArray, index) &&
						newText.right(1) == " "
					):
						#if the next line in array strts with something that isnt a character and you added a space
						newText = newText.left(-1)
			else:
				newText += "[" + siftedArray[index] +"]"
		return newText
	
	func should_end_with_space(array: PackedStringArray, index: int) -> bool:
		
		#var result : bool
		
		if(index+2>array.size()):
			#reached end of array, which is false
			return false
		
		var nextString = array[index+2]
		if nextString.length() <= 0:
			return should_end_with_space(array, index+2)

		if Util.is_char_ascii(nextString[0]):
			return true
		else:
			return false
		
	
	
	func aquolion_filter(word: String):
		var newWord : String = ""
		
		var wordLength : int 
		var wordSum : int
		var beginString : String = ""
		var endString : String = ""
		var space : bool = false
		
		var upperWord = word.to_upper()
		
		for index in upperWord.length():
			if Util.is_char_ascii(upperWord.to_upper()[index]):
				space = true
				wordLength += 1
				wordSum += upperWord.unicode_at(index) - 64
			else:
				if(index < (upperWord.length() / 2)):
					beginString += upperWord[index]
				else:
					endString += upperWord[index]
				
		#that
		var uniD : int= (wordSum / 18) +64 #49/18 = 2(+64) = B
		var uniR: int = (wordSum % 18) +64 #49%18 - 13(+64) = M
		var uniLenD: int = (wordLength / 8) + 82 #4/8 = 0 (+82) = _
		var uniLenR: int = (wordLength % 8) + 82 #4%8 = 4 (+82) = V
		
		for unicode in [uniD, uniR]:
			if unicode > 64:
				newWord += String.chr(unicode)
				
		for unicode in [uniLenD, uniLenR]:
			if unicode > 82:
				newWord += String.chr(unicode)	
		
		#if space:
			#endString += " "
		
		return beginString+newWord+endString
