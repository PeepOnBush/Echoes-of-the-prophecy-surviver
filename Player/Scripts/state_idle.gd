class_name stateIdle extends State

@onready var walk : State = $"../walk"
@onready var attack : State = $"../attack"

## What happen when the player enter this state ?
func Enter() -> void:
	print("idling")
	player.UpdateAnimation("idle")
	pass

## What happen when the player exit this state ?
func Exit() -> void:
	pass
## What happen when the _process update in this state ?
func Process(_delta : float) -> State:
	if player.direction != Vector2.ZERO:
		return walk
	player.velocity = Vector2.ZERO
	return null
	
func Physics(_delta : float) -> State:
	
	return null


func HandleInput( _event: InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		return attack
	if _event.is_action_pressed("interact"):
		PlayerManager.interact_pressed.emit()
	return null
