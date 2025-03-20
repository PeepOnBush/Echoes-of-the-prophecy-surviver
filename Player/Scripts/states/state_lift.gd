class_name StateLift extends State


@export var lift_audio : AudioStream

@onready var carry : State = $"../Carry"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

## What happen when the player enter this state ?
func Enter() -> void:
	player.UpdateAnimation("lift")
	player.animationPlayer.animation_finished.connect(stateComplete)
	player.audio.stream = lift_audio
	player.audio.play()
	pass
## What happen when the player exit this state ?
func Exit() -> void:
	
	pass 
## What happen when the _process update in this state ?
func Process(_delta : float) -> State:
	player.velocity = Vector2.ZERO
	return null
	
func Physics(_delta : float) -> State:
	return null

func HandleInput( _event : InputEvent ) -> State:
	return null

func stateComplete(_a : String) -> void:
	player.animationPlayer.animation_finished.disconnect(stateComplete)
	state_machine.changeState(carry)
	pass
