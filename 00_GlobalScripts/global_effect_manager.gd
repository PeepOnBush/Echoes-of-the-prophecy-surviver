extends Node

const DAMAGE_TEXT = preload("res://00_GlobalScripts/GlobalEffects/damage_text.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func damageText(_damage : int , _pos : Vector2, is_crit: bool = false) -> void:
	var _t = DAMAGE_TEXT.instantiate()
	add_child( _t )
	_t.start(str(_damage), _pos, is_crit)
	pass
