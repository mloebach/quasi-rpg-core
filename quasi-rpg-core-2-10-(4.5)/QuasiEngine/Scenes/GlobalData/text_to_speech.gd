#extends Global_Data
#class_name TTS
#
#var tts_voices
#var current_tts_voice
#
#
#func _ready() -> void:
	#set_tts_voices()
#
#
#func set_tts_voices():
	## One-time steps.
	## Pick a voice. Here, we arbitrarily pick the first English voice.
	#tts_voices = DisplayServer.tts_get_voices_for_language("en")
	#current_tts_voice = tts_voices[0]
#
#func tts_speak():
#
	## Say "Hello, world!".
	#DisplayServer.tts_speak("Hello, world!", current_tts_voice)
#
	#DisplayServer.beep()
	#DisplayServer.clipboard_set("Hello world")
#
#
	## Say a longer sentence, and then interrupt it.
	## Note that this method is asynchronous: execution proceeds to the next line immediately,
	## before the voice finishes speaking.
	#var long_message = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur"
	#DisplayServer.tts_speak(long_message, current_tts_voice)
#
	## Immediately stop the current text mid-sentence and say goodbye instead.
	#DisplayServer.tts_stop()
	#DisplayServer.tts_speak("Goodbye!", current_tts_voice)
