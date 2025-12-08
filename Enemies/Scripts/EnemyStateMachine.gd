class_name EnemyStateMachine extends Node

var states : Array [ EnemyState ]
var prevState : EnemyState
var currentState : EnemyState
var attack_range_node: AttackRange = null

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED
	var attack_timer = get_parent().get_node_or_null("AttackTimer")
	if attack_timer:
		# syntax: signal_name.connect( function_name )
		attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_range_node = get_parent().get_node_or_null("AttackRange")
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
	
func _on_attack_timer_timeout() -> void:
	# Find the Charge state node by name
	if currentState.name == "Charge":
		return # Already charging
	if attack_range_node:
		if attack_range_node.player_in_range == false:
			return # Player is too far, ignore the timer
	var charge_state = get_node_or_null("Charge")
	if charge_state:
		changeState(charge_state)
