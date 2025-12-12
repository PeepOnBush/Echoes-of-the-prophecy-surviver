class_name Enemy extends CharacterBody2D

signal  DirectionChanged( newDirection : Vector2 )
signal  enemyDamaged(hurt_box : HurtBox)
signal  enemyDestroyed(hurt_box : HurtBox)

const DIR_4 = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]

@export var hp : int = 10
@export var xp_reward : int = 1

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
var player : Player 
var invulnerable : bool = false

@onready var hit_box : HitBox = $HitBox
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var state_Machine : EnemyStateMachine = $EnemyStateMachine
@onready var sprite : Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	state_Machine.initialize(self)
	player = PlayerManager.player
	hit_box.Damaged.connect(_take_damage)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _physics_process(_delta):
	move_and_slide()

func UpdateAnimation( state : String) -> void:
	animationPlayer.play(state + "_" + AnimDirection())
	pass
	

func SetDirection( _new_direction : Vector2) -> bool:
	direction = _new_direction
	if direction == Vector2.ZERO:
		return false
	
	
	var direction_id : int = int( round( (direction + cardinal_direction * 0.1).angle() / TAU * DIR_4.size()) )
	var newDirection = DIR_4[direction_id]
	if newDirection == cardinal_direction:
		return false
	
	cardinal_direction = newDirection
	DirectionChanged.emit(newDirection)
	if cardinal_direction == Vector2.LEFT:
		sprite.scale.x = sprite.scale.x * (-1) 
	else:
		sprite.scale.x = sprite.scale.y
	return true


func AnimDirection() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"

func _take_damage(hurt_box : HurtBox) -> void:
	if invulnerable == true :
		return 
	hp -= hurt_box.damage
	PlayerManager.shakeCamera()
	EffectManager.damageText(hurt_box.damage, global_position + Vector2(0,-36))
	if hp >= 0:
		enemyDamaged.emit(hurt_box)
	else :
		enemyDestroyed.emit(hurt_box)
