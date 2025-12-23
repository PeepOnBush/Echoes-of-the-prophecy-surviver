class_name stateIdle extends State

@onready var walk : State = $"../walk"
@onready var attack : State = $"../attack"
@onready var dash: State = $"../Dash"
@onready var dash_attack: State = $"../DashAttack"

func Enter() -> void:
	player.UpdateAnimation("idle")
	player.velocity = Vector2.ZERO
	pass

func Exit() -> void:
	pass

func Process(_delta : float) -> State:
	if player.direction != Vector2.ZERO:
		return walk
	
	# NEW: Allow spinning in place while idle
	player.UpdateAnimation("idle")
	return null
	
func Physics(_delta : float) -> State:
	return null

func HandleInput( _event: InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		return attack
	elif _event.is_action_pressed("interact"):
		PlayerManager.Interact()
	elif _event.is_action_pressed("dash"):
		return dash
	elif _event.is_action_pressed("dash_attack"):
		return dash_attack
	return null
