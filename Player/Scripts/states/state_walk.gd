class_name stateWalking extends State

@export var walking_sound : AudioStream 
@export var moveSpeed : float = 100.0 
@onready var idle: State = $"../idle"
@onready var attack : State = $"../attack"

func Enter() -> void:
	print("walking")
	player.UpdateAnimation("walk")
	
	pass
## What happen when the player exit this state ?
func Exit() -> void:
	
	pass
## What happen when the _process update in this state ?
func Process(_delta: float) -> State:
	if player.direction == Vector2.ZERO:
		return idle
	
	player.velocity = player.direction * moveSpeed
	
	if player.SetDirection():
		player.UpdateAnimation("walk")
	return null
	
func Physics(_delta : float) -> State:
	
	return null

func HandleInput( _event: InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		return attack
	if _event.is_action_pressed("interact"):
		PlayerManager.Interact()
	return null
