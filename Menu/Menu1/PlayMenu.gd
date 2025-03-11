extends Node2D


@onready var animation_player : AnimationPlayer = $FrierenMenu/AnimationPlayer


func _ready() -> void:
	animation_player.play("Menu")
	pass

func _process(delta) -> void:
	
	pass
