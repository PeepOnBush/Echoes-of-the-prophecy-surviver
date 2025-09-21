@tool
@icon("res://GUI/dialog_system/Icons/cutscene_actor.svg")

class_name CutsceneActionAnimationMovement extends CutsceneAction

enum Method { DURATION, SPEED}

@export var timing_method : Method = Method.DURATION
@export var object_to_move : Node2D
@export var transition_type : Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR
@export var easing_method : Tween.EaseType = Tween.EaseType.EASE_IN_OUT
@export_range(0.0, 10.0,0.05, "s") var move_duration : float = 0.5
@export_range(10.0, 1000.0,0.05, "px/s") var move_speed : float = 200.0
@export var animation_speed_factor : float = 40.0

var target_location : Vector2 = Vector2.ZERO
var move_direction : Vector2 = Vector2.ZERO
var distance_to_target : float = 0.0


func _ready() -> void:
	target_location = global_position
	pass

func play() -> void:
	if object_to_move:
		object_to_move.process_mode = Node.PROCESS_MODE_ALWAYS
		distance_to_target = calculateDistanceToTarget()
		getMoveDirection()
		if timing_method == Method.SPEED:
			move_duration = distance_to_target / move_speed
		else : 
			move_speed = distance_to_target / move_duration
		
		if object_to_move is NPC :
			var npc : NPC = object_to_move
			npc.doBehavior = false
			npc.state = "walk"
			npc.direction = move_direction
			npc.updateDirection(target_location)
			npc.updateAnimation()
			npc.animation.speed_scale = move_speed / animation_speed_factor
		var tween : Tween = create_tween()
		tween.set_ease(easing_method)
		tween.set_trans(transition_type)
		tween.tween_property(object_to_move,"global_position",target_location,move_duration)
		tween.tween_callback(onTweenFinish)
		pass
	else:
		finished.emit()
	pass

func onTweenFinish() -> void:
	object_to_move.process_mode = Node.PROCESS_MODE_INHERIT
	if object_to_move is NPC:
		var npc : NPC = object_to_move
		npc.doBehavior = false
		npc.state = "idle"
		npc.animation.speed_scale = 1
		npc.process_mode = Node.PROCESS_MODE_INHERIT
	
	finished.emit()
	pass

func getMoveDirection() -> void:
	if object_to_move:
		move_direction = object_to_move.global_position.direction_to(target_location)
	pass

func calculateDistanceToTarget() -> float:
	return object_to_move.global_position.distance_to(target_location)

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO,3, Color.RED)
		draw_circle(Vector2.ZERO,10, Color(1.0,0,0,0.5),false,1.0)
	pass
