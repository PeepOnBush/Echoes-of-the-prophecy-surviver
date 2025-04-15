class_name DarkWizardBoss extends Node2D

const ENERGY_EXPLOSION_SCENE : PackedScene = preload("res://Levels/Dungeon01/dark_wizard/energy_explosion.tscn")
const ENERGY_ORB_SCENE : PackedScene = preload("res://Levels/Dungeon01/dark_wizard/energy_orb.tscn")

@export var max_hp : int = 10
var hp : int = 10

var audio_hurt : AudioStream = preload("res://Levels/Dungeon01/dark_wizard/Audio/boss_hurt.wav")

var current_position : int = 0
var positions : Array[ Vector2 ]
var beam_attacks : Array[BeamAttack]
var audio_shoot : AudioStream = preload("res://Levels/Dungeon01/dark_wizard/Audio/boss_fireball.wav")
var damage_count : int = 0


@onready var animation_player_damage: AnimationPlayer = $BossNode/AnimationPlayer_damage
@onready var cloak_animation_player: AnimationPlayer = $BossNode/CloakSprite/AnimationPlayer
@onready var animation_player: AnimationPlayer = $BossNode/AnimationPlayer
@onready var audio: AudioStreamPlayer2D = $BossNode/AudioStreamPlayer2D
@onready var boss_node: Node2D = $BossNode
@onready var boss_defeated: PersistentDataHandler = $PersistentDataHandler
@onready var hurt_box: HurtBox = $BossNode/HurtBox
@onready var hit_box: HitBox = $BossNode/HitBox
@onready var door_block: TileMapLayer = $"../DoorBlock"


@onready var hand_01: Sprite2D = $"BossNode/CloakSprite/Hand-01"
@onready var hand_02: Sprite2D = $"BossNode/CloakSprite/Hand-02"
@onready var hand_01_up: Sprite2D = $"BossNode/CloakSprite/Hand-01-up"
@onready var hand_02_up: Sprite2D = $"BossNode/CloakSprite/Hand-02-up"
@onready var hand_01_side: Sprite2D = $"BossNode/CloakSprite/Hand-01-side"
@onready var hand_02_side: Sprite2D = $"BossNode/CloakSprite/Hand-02-side"




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boss_defeated.getValue()
	if boss_defeated.value == true:
		door_block.enabled = false
		queue_free()
		return
		
	
	
	hp = max_hp
	PlayerHud.showBossHealth( "Dark Wizard" )
	hit_box.Damaged.connect(damageTaken)
	
	for c in $PositionTarget.get_children():
		positions.append( c.global_position )
	$PositionTarget.visible = false
	
	for b in $BeamAttacks.get_children():
		beam_attacks.append(b)
	
	teleport(0)
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	hand_01_up.position = hand_01.position
	hand_01_up.frame = hand_01.frame + 4
	hand_02_up.position = hand_02.position
	hand_02_up.frame = hand_02.frame + 4
	hand_01_side.position = hand_01.position
	hand_01_side.frame = hand_01.frame + 8
	hand_02_side.position = hand_02.position
	hand_02_side.frame = hand_02.frame + 12
	
	pass

func teleport( _location : int ) -> void:
	animation_player.play("disappear")
	enableHitBoxes(false)
	damage_count = 0
	
	if hp < max_hp:
		shootOrb()
	
	await get_tree().create_timer(1).timeout
	boss_node.global_position = positions[_location]
	current_position = _location
	updateAnimation()
	animation_player.play("appear")
	await animation_player.animation_finished
	idle()
	pass

func idle() -> void:
	enableHitBoxes()
	
	if randf() >= float(hp / max_hp) : # the lower the health get the higher probability this happening will be
		animation_player.play("idle")
		await animation_player.animation_finished
	
	if damage_count < 1:
		energyBeamAttack()
		animation_player.play("cast_spell")
		await animation_player.animation_finished
	
	if hp < 1 : 
		return
	
	var _t : int = current_position
	while _t == current_position:
		_t = randi_range(0,3)
	teleport(_t)
	pass

func updateAnimation() -> void:
	boss_node.scale = Vector2(1,1)
	
	hand_01.visible = false
	hand_02.visible = false
	hand_01_up.visible = false
	hand_02_up.visible = false
	hand_01_side.visible = false
	hand_02_side.visible = false
	
	
	if current_position == 0:
		cloak_animation_player.play("down")
		hand_01.visible = true
		hand_02.visible = true
	elif current_position == 2:
		cloak_animation_player.play("up")
		hand_01_up.visible = true
		hand_02_up.visible = true
	else:
		cloak_animation_player.play("side")
		hand_01_side.visible = true
		hand_02_side.visible = true
		if current_position == 1:
			boss_node.scale = Vector2(-1,1)
	pass

func energyBeamAttack() -> void:
	var _b : Array[ int ]
	match current_position:
		0,2:
			if current_position == 0:
				_b.append(0)
				_b.append(randi_range(1,2))
			else:
				_b.append(2)
				_b.append(randi_range(0,1))
			if hp < 5:
				_b.append(randi_range(3,5))
		1,3:
			if current_position == 3:
				_b.append(5)
				_b.append(randi_range(3,4))
			else:
				_b.append(3)
				_b.append(randi_range(4,5))
			if hp < 5:
				_b.append(randi_range(0,2))
	for b in _b:
		beam_attacks[b].attack()
	pass

func shootOrb() -> void:
	var eb : Node2D = ENERGY_ORB_SCENE.instantiate()
	eb.global_position = boss_node.global_position + Vector2(0,-34)
	get_parent().add_child.call_deferred(eb)
	playAudio( audio_shoot )



func damageTaken(_hurt_box : HurtBox ) -> void:
	if animation_player_damage.current_animation == "damaged" or _hurt_box.damage == 0:
		return
	playAudio(audio_hurt)
	hp = clampi(hp - _hurt_box.damage, 0, max_hp )
	damage_count += 1
	PlayerHud.updateBossHealth(hp, max_hp)
	animation_player_damage.play("damaged")
	animation_player_damage.seek(0)
	animation_player_damage.queue("default")
	
	if hp < 1 :
		defeat()
	pass

func playAudio(_a : AudioStream) -> void:
	audio.stream = _a
	audio.play()
	pass

func defeat() -> void:
	animation_player.play("destroy")
	enableHitBoxes(false)
	PlayerHud.hideBossHealth()
	boss_defeated.setValue()
	await animation_player.animation_finished
	door_block.enabled = false
	pass

func enableHitBoxes( _v : bool = true) -> void:
	hit_box.set_deferred("monitorable", _v)
	hurt_box.set_deferred("monitoring", _v)
	pass

func explosion( _p : Vector2 = Vector2.ZERO) -> void:
	var e : Node2D = ENERGY_EXPLOSION_SCENE.instantiate()
	e.global_position = boss_node.global_position + _p
	get_parent().add_child.call_deferred(e)
	pass
