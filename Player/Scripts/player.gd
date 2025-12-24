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

var arrow_count : int = 5 : set = _setArrowCount
var bomb_count : int = 10 : set = _setBombCount
var stamina : float = 100.0
var stamina_regen : float = 20.0 # How much per second

@onready var audio : AudioStreamPlayer2D = $Audio/AudioStreamPlayer2D
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $newSprite2D
@onready var state_Machine : playerStateMachine = $StateMachine
@onready var hit_box : HitBox = $HitBox
@onready var effect_animation_player : AnimationPlayer = $EffectAnimationPlayer
@onready var lift: StateLift = $StateMachine/Lift
@onready var held_item: Node2D = $Sprite2D/HeldItem
@onready var carry: StateCarry = $StateMachine/Carry
@onready var player_abilities: PlayerAbilities = $Abilities

@export var max_stamina : float = 100.0

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
	
	direction = Vector2(
		Input.get_axis("left","right"),
		Input.get_axis("up", "down")
	).normalized()
	# Regen Stamina
	if stamina < max_stamina:
		stamina += stamina_regen * _delta
		stamina = min(stamina, max_stamina)
		PlayerHud.updateStamina(stamina, max_stamina)
	# 2. FACING LOGIC (Mouse) - Only if not stunned/dead
	# Check state to prevent spinning while stunned/dying
	@warning_ignore("incompatible_ternary")
	var current_state_name = state_Machine.currentState.name if state_Machine.currentState else ""
	if current_state_name != "Stun" and current_state_name != "Death":
		update_facing_direction()

	pass 


func _physics_process(_delta):
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		PlayerManager.shakeCamera()
	pass


func update_facing_direction() -> void:
	var mouse_pos = get_global_mouse_position()
	var aim_direction = (mouse_pos - global_position).normalized()
	
	# Calculate cardinal direction based on AIM, not movement
	var direction_id : int = int( round( (aim_direction + cardinal_direction * 0.1).angle() / TAU * DIR_4.size()) )
	var newDirection = DIR_4[direction_id]
	
	if newDirection != cardinal_direction:
		cardinal_direction = newDirection
		DirectionChanged.emit(newDirection)
	
	# --- THE FIX ---
	# Get the current vertical size (absolute value to ignore any accidental negative Y)
	var current_scale = abs(sprite.scale.y)
	
	# Sprite Flipping based on Mouse X
	if mouse_pos.x < global_position.x:
		# If your sprite faces LEFT by default, this should be Positive
		sprite.scale.x = current_scale 
	else:
		# And this should be Negative to flip it Right
		sprite.scale.x = -current_scale

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
		EffectManager.damageText(_hurt_box.damage, global_position + Vector2(0,-36))

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

func _setArrowCount(value : int) -> void:
	arrow_count = value
	PlayerHud.update_arrow_count(value)
	pass

func _setBombCount(value : int) -> void:
	bomb_count = value
	PlayerHud.update_bomb_count(value)
	pass

func enableOrbitDarkGemController()-> void:
	get_node("OrbitController").activate()
	pass
