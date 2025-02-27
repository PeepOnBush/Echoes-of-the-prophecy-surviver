extends CanvasLayer

@onready var animationPlayer : AnimationPlayer = $Control/AnimationPlayer

func fade_out() -> bool:
	animationPlayer.play("faded_out")
	await animationPlayer.animation_finished
	return true

func fade_in() -> bool:
	animationPlayer.play("faded_in")
	await animationPlayer.animation_finished
	return true
