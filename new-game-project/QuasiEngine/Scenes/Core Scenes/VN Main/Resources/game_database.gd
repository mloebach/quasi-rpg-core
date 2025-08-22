extends Resource


class_name VN_Database


@export_group("Characters")

@export_file("*.tres") var characters : Array[String] = [
	
]

@export_group("Visual Assets")
@export var cgs : Dictionary[String, String] = {
	"WhiteScreen": "res://Game Files/Zenith Day August 23/Visual Assets/CGs/WhiteScreen.png",
	"BlackScreen": "res://Game Files/Zenith Day August 23/Visual Assets/CGs/BlackScreen.png",
	"TitleScreenPlaceholder": "res://Game Files/Zenith Day August 23/Visual Assets/CGs/title_screen_placeholder.png",
	"VSDarkHusk1" : "res://Game Files/Zenith Day August 23/Visual Assets/CGs/Prelude/VsBlackHusk1.png",
	"VSDarkHusk2" : "res://Game Files/Zenith Day August 23/Visual Assets/CGs/Prelude/VsBlackHusk2.png",
	"VSDarkHusk3" : "res://Game Files/Zenith Day August 23/Visual Assets/CGs/Prelude/VsBlackHusk3.png",
	"VSDarkHusk4" : "res://Game Files/Zenith Day August 23/Visual Assets/CGs/Prelude/VsBlackHusk4.png",
	"VSDarkHusk5" : "res://Game Files/Zenith Day August 23/Visual Assets/CGs/Prelude/VsBlackHusk5.png",
	"VSDarkHusk6" : "res://Game Files/Zenith Day August 23/Visual Assets/CGs/Prelude/VsBlackHusk6.png",
	"VSDarkHusk7" : "res://Game Files/Zenith Day August 23/Visual Assets/CGs/Prelude/VsBlackHusk7.png",
	"VSDarkHusk8" : "res://Game Files/Zenith Day August 23/Visual Assets/CGs/Prelude/VsBlackHusk8.png",
	"VSDarkHusk9" : "res://Game Files/Zenith Day August 23/Visual Assets/CGs/Prelude/VsBlackHusk9.png",
	"VSDarkHusk10" : "res://Game Files/Zenith Day August 23/Visual Assets/CGs/Prelude/VsBlackHusk10.png",
	"VSDarkHusk11" : "res://Game Files/Zenith Day August 23/Visual Assets/CGs/Prelude/VsBlackHusk11.png",
	"VSDarkHusk12" : "res://Game Files/Zenith Day August 23/Visual Assets/CGs/Prelude/VsBlackHusk12.png",
	"VSDarkHusk13" : "res://Game Files/Zenith Day August 23/Visual Assets/CGs/Prelude/VsBlackHusk13.png",
	"VSDarkHusk14" : "res://Game Files/Zenith Day August 23/Visual Assets/CGs/Prelude/VsBlackHusk14.png",
	"VSDarkHusk15" : "res://Game Files/Zenith Day August 23/Visual Assets/CGs/Prelude/VsBlackHusk15.png",
}

@export_group("Strings")

@export var title_screen_string = "Pilgrimage to Zenith"
@export var title_screen_subtitle_on := true
@export var title_screen_subtitle = "Bizarro Draft"

@export_group("Printers")

@export var default_printer := "Ink"

@export_file("*.tres") var printers : Array[String] = [
	"res://QuasiEngine/Default GUI/Printers/dialogue_printer.tres",
	"res://QuasiEngine/Default GUI/Printers/ink_printer.tres"
]

@export_group("Writing")

#figure out way to change this from string to all scripts in pool
@export var initial_script : String

@export var script_pool: Array[ScenarioScript]


@export_group("Options")


@export var wait_by_default := true
