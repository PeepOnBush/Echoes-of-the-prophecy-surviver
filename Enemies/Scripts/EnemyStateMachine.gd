class_name EnemyStateMachine extends Node

var states : Array [ EnemyState ]
var prevState : EnemyState
var currentState : EnemyState


# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	changeState( currentState.Process(delta))
	pass

func _physics_process(delta):
	changeState(currentState.Physics(delta))
	pass

func initialize( _enemy : Enemy) -> void :
	states = []
	for c in get_children():
		if c is EnemyState:
			states.append(c)


	for s in states:
		s.enemy = _enemy
		s.state_machine = self
		s.init()
	
	if states.size() > 0:
		changeState(states[0])
		process_mode = Node.PROCESS_MODE_INHERIT
	
	pass

func changeState(newState : EnemyState) -> void:
	if newState == null || newState == currentState:
		return
	
	if currentState:
		currentState.Exit()
	
	prevState = currentState
	currentState = newState
	currentState.Enter()
	
