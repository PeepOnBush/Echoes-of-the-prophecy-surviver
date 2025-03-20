class_name StateCarry extends State

@export var move_speed : float = 100.0
@export var throw_audio : AudioStream

var walking : bool = false
var throwable : Throwable



@onready var idle: stateIdle = $"../idle"
@onready var stun: stateStun = $"../Stun"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func init() -> void:
	pass

## What happen when the player enter this state ?
func Enter() -> void:
	player.UpdateAnimation("carry")
	walking = false
	pass
## What happen when the player exit this state ?
func Exit() -> void:
	if throwable:
		#throwable.throw_direction = player.cardinal_direction
		throwable.throw_direction = player.direction
		if state_machine.nextState == stun:
			throwable.drop()
			pass
		else:
			player.audio.stream = throw_audio
			player.audio.play()
			throwable.throw()
			pass
		
		pass
	pass 
## What happen when the _process update in this state ?
func Process(_delta : float) -> State:
	if player.direction == Vector2.ZERO:
		walking = false
		player.UpdateAnimation("carry")
	elif player.SetDirection() or walking == false:
		player.UpdateAnimation("carry_walk")
		walking = true
	
	player.velocity = player.direction * move_speed
	return null
	
func Physics(_delta : float) -> State:
	return null

func HandleInput( _event : InputEvent ) -> State:
	if _event.is_action_pressed("attack") or _event.is_action_pressed("interact"):
		return idle 
	return null
