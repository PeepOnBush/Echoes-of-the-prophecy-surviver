extends Area2D


func _ready() -> void:
	body_entered.connect( onBodyEntered)
	body_exited.connect( onBodyExited)

func onBodyEntered( b : Node2D) -> void:
	if b is PushableStatue:
		b.pushDirection = PlayerManager.player.direction
	pass

func onBodyExited( b : Node2D) -> void:
	if b is PushableStatue:
		b.pushDirection = Vector2.ZERO
	pass
