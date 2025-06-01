class_name Player extends CharacterBody2D

signal DirectionChanged( newDirection : Vector2)
signal PlayerDamaged(hurt_box : HurtBox)

const DIR_4 = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO

var invulnerable : bool = false
var hp : int = 6
var max_hp : int = 6
var xp : int = 0
var level : int = 1
var defense : int = 1
var defense_bonus  : int = 0
var attack : int = 1 :
	set(v) :
		attack = v
		updateDamageValue()



@onready var audio : AudioStreamPlayer2D = $Audio/AudioStreamPlayer2D
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
@onready var state_Machine : playerStateMachine = $StateMachine
@onready var hit_box : HitBox = $HitBox
@onready var effect_animation_player : AnimationPlayer = $EffectAnimationPlayer
@onready var lift: StateLift = $StateMachine/Lift
@onready var held_item: Node2D = $Sprite2D/HeldItem
@onready var carry: StateCarry = $StateMachine/Carry

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerManager.player = self
	state_Machine.Initialize(self)
	hit_box.Damaged.connect(_take_damage)
	update_hp(99)
	updateDamageValue()
	PlayerManager.leveled_up.connect(onPlayerLevelUp)
	PlayerManager.INVENTORY_DATA.equipment_changed.connect(onEquipmentChanged)
	pass # Replace with function body.
 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process( _delta ):
	
	#direction.x = Input.get_action_strength("Right") - Input.get_action_strength("Left");
	#direction.y = Input.get_action_strength("Down") - Input.get_action_strength("Up");
	
	direction = Vector2(
		Input.get_axis("left","right"),
		Input.get_axis("up", "down")
	).normalized()
	pass 


func _physics_process(_delta):
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		PlayerManager.shakeCamera()
	pass


func SetDirection() -> bool:
	if direction == Vector2.ZERO:
		return false
	
	
	var direction_id : int = int( round( (direction + cardinal_direction * 0.1).angle() / TAU * DIR_4.size()) )
	var newDirection = DIR_4[direction_id]
	if newDirection == cardinal_direction:
		return false
	
	cardinal_direction = newDirection
	DirectionChanged.emit(newDirection)
	sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	return true

func UpdateAnimation( state : String) -> void:
	animationPlayer.play(state + "_" + AnimDirection())
	pass
	
func AnimDirection() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"

func _take_damage(_hurt_box : HurtBox) -> void:
	if invulnerable == true:
		return
	if hp > 0:
		var dmg : int = _hurt_box.damage
		
		
		if dmg > 0:
			dmg = clampi(dmg - defense - defense_bonus, 1, dmg )
		
		update_hp( -dmg )
		PlayerDamaged.emit(_hurt_box)
		
	pass

func update_hp( _delta : int ) -> void:
	hp = clampi(hp + _delta, 0, max_hp)
	PlayerHud.updateHp(hp,max_hp)
	pass
	
func make_invulnerable( _duration : float = 1.5) -> void:
	invulnerable = true
	hit_box.monitoring = false
	
	await get_tree().create_timer( _duration ).timeout
	
	invulnerable = false
	hit_box.monitoring = true
	pass

func pickupItem(_t : Throwable) -> void:
	state_Machine.changeState(lift)
	carry.throwable = _t
	pass

func revivePlayer() -> void:
	update_hp(99)
	state_Machine.changeState($StateMachine/idle)
	pass

func onPlayerLevelUp() -> void:
	effect_animation_player.play("level_up")
	update_hp(max_hp)
	pass

func updateDamageValue() -> void:
	var damageValue : int = attack + PlayerManager.INVENTORY_DATA.getAttackBonus()
	%AttackHurtBox.damage = damageValue 
	%ChargeSpinHurtBox.damage = damageValue * 2
	pass

func onEquipmentChanged() -> void:
	updateDamageValue()
	defense_bonus = PlayerManager.INVENTORY_DATA.getDefendBonus()
	pass
