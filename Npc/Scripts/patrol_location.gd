@tool
class_name PatrolLocation extends Node2D

signal transform_changed



@export var wait_time : float = 0.0:
	set(v) :
		wait_time = v 
		updateWaitTimeLabel()

var target_position : Vector2 = Vector2.ZERO

func _enter_tree()-> void:
	set_notify_transform(true)

func _notification(what : int ) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		transform_changed.emit()

func _ready() -> void:
	target_position = global_position
	updateWaitTimeLabel()
	if Engine.is_editor_hint():
		return
	
	$Sprite2D.queue_free()
	pass
func updateWaitTimeLabel() -> void:
	if Engine.is_editor_hint():
		$Sprite2D/Label2.text = "wait:" + str( snappedf(wait_time,0.1 )) + " secs"
	pass

func updateLabel( _s : String) -> void:
	$Sprite2D/Label.text = _s
	pass

func updateLine( nextLocation : Vector2) -> void:
	var line : Line2D = $Sprite2D/Line2D
	line.points[1] = nextLocation - position
