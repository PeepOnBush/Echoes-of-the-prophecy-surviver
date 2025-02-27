class_name VisionArea extends Area2D

signal player_entered()
signal player_exited()


func _ready() -> void:
	body_entered.connect(onBodyEnter)
	body_exited.connect(onBodyExit)
	var p = get_parent()
	if p is Enemy:
		p.DirectionChanged.connect(onDirectionChange)
	pass

func onBodyEnter( _b : Node2D) -> void:
	if _b is Player:
		player_entered.emit()
	pass

func onBodyExit(_b : Node2D) -> void:
	if _b is Player:
		player_exited.emit()
	pass

func onDirectionChange( new_direction : Vector2) -> void:
	match new_direction:
		Vector2.DOWN:
			rotation_degrees = 0
		Vector2.UP:
			rotation_degrees = 180
		Vector2.LEFT:
			rotation_degrees = 90
		Vector2.RIGHT:
			rotation_degrees = -90
		_:
			rotation_degrees = 0
	pass
