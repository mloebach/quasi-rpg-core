extends Resource


class_name VN_Database


@export_group("Strings")

@export var title_screen_string = "Pilgrimage to Zenith"
@export var title_screen_subtitle_on := true
@export var title_screen_subtitle = "Bizarro Draft"

@export_group("Writing")

#figure out way to change this from string to all scripts in pool
@export var initial_script : String

@export var script_pool: Array[ScenarioScript]


@export_group("Options")

@export var wait_by_default := true
