class_name PushableStatue extends RigidBody2D

@export var pushSpeed : float = 30.0

var pushDirection : Vector2 = Vector2.ZERO : set = setPush

@onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D

func _physics_process( _delta : float) -> void:
	linear_velocity = pushDirection * pushSpeed
	pass

func setPush( value : Vector2 ) -> void:
	pushDirection = value
	if pushDirection == Vector2.ZERO:
		audio.stop()
	else:
		audio.play()
	pass
