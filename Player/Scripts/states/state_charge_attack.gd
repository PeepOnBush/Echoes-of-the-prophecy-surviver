class_name StateChargeAttack extends State
 
@export var charge_duration : float = 1.0
@export var move_speed : float = 80.0
@export var sfx_charged : AudioStream
@export var sfx_spin : AudioStream


@onready var idle: stateIdle = $"../idle"
@onready var charge_hurt_box: HurtBox = %ChargeHurtBox
@onready var charge_spin_hurt_box: HurtBox = %ChargeSpinHurtBox
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"
@onready var spin_animation_player: AnimationPlayer = $"../../Sprite2D/SpinEffectSprite2D/AnimationPlayer"
@onready var spin_effect_sprite_2d: Sprite2D = $"../../Sprite2D/SpinEffectSprite2D"
@onready var gpu_particles_2d: GPUParticles2D = $"../../Sprite2D/ChargeHurtBox/GPUParticles2D"

var timer : float = 0.0
var walking : bool = false
var is_attacking : bool = false 
var particles : ParticleProcessMaterial



func _ready() -> void:
	pass # Replace with function body.

func init() -> void:
	gpu_particles_2d.emitting = false
	particles = gpu_particles_2d.process_material as ParticleProcessMaterial
	spin_effect_sprite_2d.visible = false
	pass

## What happen when the player enter this state ?
func Enter() -> void:
	timer = charge_duration
	is_attacking = false
	walking = false
	charge_hurt_box.monitoring = true
	gpu_particles_2d.emitting = true
	gpu_particles_2d.amount = 4
	gpu_particles_2d.explosiveness = 0
	particles.initial_velocity_min = 10
	particles.initial_velocity_max = 30
	pass
## What happen when the player exit this state ?
func Exit() -> void:
	charge_hurt_box.monitoring = false
	charge_spin_hurt_box.monitoring = false
	spin_effect_sprite_2d.visible = false
	gpu_particles_2d.emitting = false
	pass 
## What happen when the _process update in this state ?
func Process(_delta : float) -> State:
	#handle timer, when timer's done, let the player know the charge complete
	if timer > 0:
		timer -= _delta
		if timer <= 0:
			timer = 0  
			chargeComplete()
	
	
	if is_attacking == false:
		if player.direction == Vector2.ZERO:
			walking = false
			player.UpdateAnimation("charge")
		elif walking == false:
			walking = true
			player.UpdateAnimation("charge_walk")
			pass
	player.velocity = player.direction * move_speed
	
	return null

func chargeComplete()-> void:
	playAudio(sfx_charged)
	gpu_particles_2d.amount = 50
	gpu_particles_2d.explosiveness = 1
	particles.initial_velocity_min = 50
	particles.initial_velocity_max = 100
	await get_tree().create_timer(0.5).timeout
	gpu_particles_2d.amount = 10
	gpu_particles_2d.explosiveness = 0
	particles.initial_velocity_min = 10
	particles.initial_velocity_max = 30

func Physics(_delta : float) -> State:
	return null

func HandleInput( _event : InputEvent ) -> State:
	if _event.is_action_released("attack"):
		if timer > 0:
			return idle
		elif is_attacking == false:
			chargeAttack()
	return null

func chargeAttack() -> void:
	is_attacking = true
	player.animationPlayer.play("charge_attack")
	player.animationPlayer.seek(getSpinFrame())
	playAudio(sfx_spin)
	spin_effect_sprite_2d.visible = true
	spin_animation_player.play("spin")
	var _duration : float = player.animationPlayer.current_animation_length
	player.make_invulnerable( _duration )
	charge_spin_hurt_box.monitoring = true
	await get_tree().create_timer(_duration * 0.875).timeout
	
	state_machine.changeState(idle)
	pass

func getSpinFrame() -> float:
	var interval : float = 0.05
	match player.cardinal_direction:
		Vector2.DOWN:
			return interval * 0
		Vector2.UP:
			return interval * 4
		_:
			return interval * 6

func playAudio(_audio : AudioStream) -> void:
	audio_stream_player_2d.stream = _audio
	audio_stream_player_2d.play()
	pass
