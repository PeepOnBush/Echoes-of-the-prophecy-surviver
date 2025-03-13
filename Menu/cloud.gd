extends Node2D

@export var speed = 50.0

func _process(delta):
	position.x -= speed * delta
	if position.x < -100:  # Adjust based on your screen width
		position.x = 1000  # Reset to the right side
