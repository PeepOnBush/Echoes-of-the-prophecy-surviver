class_name stateCutscene extends State

@onready var idle: stateIdle = $"../idle"

func init() -> void:
	DialogSystem.started.connect(onDialogStarted)
	DialogSystem.finished.connect(onDialogFinished)
	pass
## What happen when the player enter this state ?
func Enter() -> void:
	player.UpdateAnimation("idle")
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	pass

## What happen when the player exit this state ?
func Exit() -> void:
	player.process_mode = Node.PROCESS_MODE_INHERIT
	pass
## What happen when the _process update in this state ?
func Process(_delta : float) -> State:
	player.velocity = Vector2.ZERO
	return null
	
func Physics(_delta : float) -> State:
	return null

func HandleInput( _event: InputEvent) -> State:
	return null

func onDialogFinished() -> void:
	state_machine.changeState(idle)
	pass
func onDialogStarted() -> void:
	state_machine.changeState(self)
	pass
