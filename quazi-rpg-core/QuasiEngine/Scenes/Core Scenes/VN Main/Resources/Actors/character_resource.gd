extends Resource
class_name Char_Resource

const DEFAULT_POSE = "Default"

@export_multiline var hint : String

@export_group("Name")
@export var name : String
@export var display_name : String
@export var full_name: String

@export_group("Visuals")

#@export var starting_direction : LookDirections = LookDirections.Left

@export_subgroup("Character Color")
@export var use_character_color : bool
@export var character_color : Color

@export_group("Sprites")
@export var DefaultSprite : String = DEFAULT_POSE
@export var sprite_resources : Dictionary[String, Texture2D] = {}
@export var icon_resources : Dictionary[String, Texture2D] = {}

@export_group("Variables")
@export var custom_variables : Dictionary[String, String] = {}
@export var tags : Array[String] = []
