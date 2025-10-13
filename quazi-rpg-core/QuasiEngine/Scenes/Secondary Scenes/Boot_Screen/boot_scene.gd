extends Control

@onready var logo = $Logo

signal switch_scene

func _ready() -> void:
	logo.modulate.a = 0.0
	await get_tree().create_timer(0.5).timeout
	_opening_animation()

func _opening_animation() -> void:
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(logo, "modulate:a", 1.0, 3.0)
	#await get_tree().create_timer(2.5).timeout
	tween.tween_property(logo, "modulate:a", 0.0, 3.0)
	await get_tree().create_timer(6.0).timeout
	
	_move_to_next_scene()

func _move_to_next_scene():
	if(GlobalData.game_db.skip_to_new):
		switch_scene.emit("vn")
	else:
		switch_scene.emit("title")
