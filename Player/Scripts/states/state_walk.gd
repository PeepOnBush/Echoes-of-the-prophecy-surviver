class_name stateWalking extends State

@export var walking_sound : AudioStream 
@export var moveSpeed : float = 100.0 
@onready var idle: State = $"../idle"
@onready var attack : State = $"../attack"
@onready var dash: State = $"../Dash"
@onready var dash_attack: State = $"../DashAttack"

func Enter() -> void:
	# print("walking")
	player.UpdateAnimation("walk")
	pass

func Exit() -> void:
	pass

func Process(_delta: float) -> State:
	# 1. Stop if no input
	if player.direction == Vector2.ZERO:
		return idle
	
	# 2. Move (WASD)
	player.velocity = player.direction * moveSpeed
	
	# 3. Update Animation
	# We call this every frame. Player.gd handles the "Up/Down/Side" based on mouse.
	# So if you hold W (Up) but aim Right, this plays "walk_side".
	player.UpdateAnimation("walk")
	
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
