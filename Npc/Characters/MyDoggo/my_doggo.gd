class_name my_doggo extends CharacterBody2D

@onready var animation_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("idle")
	pass
