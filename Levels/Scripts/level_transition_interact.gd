@tool
class_name LevelTransitionInteract extends LevelTransition

func _ready() -> void:
	super()
	area_entered.connect(onAreaEntered)
	area_exited.connect(onAreaExited)


func onAreaEntered(_a : Area2D ) -> void:
	PlayerManager.interact_pressed.connect(playerInteract)
	pass

func onAreaExited( _a : Area2D ) -> void:
	PlayerManager.interact_pressed.disconnect(playerInteract)
	pass

func playerInteract() -> void:
	_player_entered(PlayerManager.player)
	pass

func _update_area() -> void:
	super()
	collision_shape.shape.size = Vector2(32,32) # can be remove if want to reshape
	pass
