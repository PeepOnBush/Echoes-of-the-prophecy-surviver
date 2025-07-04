class_name StateShoot extends State



const ARROW = preload("res://Interactables/arrow/arrow.tscn")
@onready var idle: State = $"../idle"

var direction : Vector2 = Vector2.ZERO
var next_state : State = null


## What happen when the player enter this state ?
func Enter() -> void:
	player.UpdateAnimation("bow")
	player.animationPlayer.animation_finished.connect( onAnimationFinished )
	direction = player.cardinal_direction #multiply for -1 to go backward
	
	var arrow : Arrow = ARROW.instantiate()
	player.add_sibling(arrow)
	arrow.global_position = player.global_position + (direction * 32)
	arrow.shoot(direction)
	pass
## What happen when the player exit this state ?
func Exit() -> void:
	player.animationPlayer.animation_finished.disconnect( onAnimationFinished )
	next_state = null
	pass 
## What happen when the _process update in this state ?
func Process(_delta : float) -> State:
	player.velocity = Vector2.ZERO
	return next_state
	
func Physics(_delta : float) -> State:
	return null

func HandleInput( _event : InputEvent ) -> State:
	return null

func onAnimationFinished(animation_name : String) -> void: # add in the bracket animation_name : String if needed
	next_state = idle
	pass
