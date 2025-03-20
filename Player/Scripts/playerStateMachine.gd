class_name playerStateMachine extends Node


var states : Array [ State ]
var prevState : State
var currentState : State
var nextState : State
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	changeState( currentState.Process(delta))
	pass

func physicsProcess(delta):
	changeState( currentState.Physics(delta))
	pass

func _unhandled_input(event : InputEvent) -> void:
	if currentState :
		var newState = currentState.HandleInput(event)
		if newState:
			changeState(newState)
	pass
	
func Initialize( _player : Player) -> void:
	states = []
	for c in get_children():
		if c is State:
			states.append(c)

	if states.size() == 0:
		return
	
	states[0].player = _player
	states[0].state_machine = self
	
	for state in states:
		state.init()
	
	changeState( states[0] )
	process_mode = Node.PROCESS_MODE_INHERIT

func changeState(newState : State) -> void:
	if newState == null || newState == currentState:
		return
	
	nextState = newState
	
	if currentState:
		currentState.Exit()
	
	prevState = currentState
	currentState = newState
	currentState.Enter()
	
