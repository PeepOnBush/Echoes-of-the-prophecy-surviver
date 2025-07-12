class_name StateDashAttack extends State

@export var move_speed : float = 200
@export var effect_delay : float = 0.1
@export var dash_audio : AudioStream
@onready var idle: State = $"../idle"
@onready var attack: State  = $"../attack"
@onready var hurt_box : HurtBox = %AttackHurtBox

var direction : Vector2 = Vector2.ZERO
var next_state : State = null
var effect_timer : float = 0
var attacking : bool = false


## What happen when the player enter this state ?
func Enter() -> void:
	player.invulnerable = true
	player.UpdateAnimation("attack")
	player.animationPlayer.animation_finished.connect( onAnimationFinished )
	direction = player.direction 
	if direction == Vector2.ZERO:
		direction = player.cardinal_direction #multiply for -1 to go backward
	if dash_audio:
		player.audio.stream = dash_audio
		player.audio.play()
	attacking = true
	if attacking:
		hurt_box.monitoring = true
	effect_timer = 0
	pass
## What happen when the player exit this state ?
func Exit() -> void:
	player.invulnerable = false
	player.animationPlayer.animation_finished.disconnect( onAnimationFinished )
	next_state = null
	attacking = false
	hurt_box.monitoring = false
	pass 
## What happen when the _process update in this state ?
func Process(_delta : float) -> State:
	player.velocity = direction * move_speed
	effect_timer -= _delta
	if effect_timer < 0:
		effect_timer = effect_delay
		spawnEffect()
	return next_state
	
func Physics(_delta : float) -> State:
	return null

func HandleInput( _event : InputEvent ) -> State:
	return null

@warning_ignore("unused_parameter")
func onAnimationFinished(animation_name : String) -> void: # add in the bracket animation_name : String if needed
	next_state = idle
	pass

func spawnEffect() -> void:
	var effect : Node2D = Node2D.new()
	player.get_parent().add_child(effect)
	effect.global_position = player.global_position - Vector2(0, 0.1)
	effect.modulate = Color(1.5,0.2,1.25,0.75)
	
	var spriteEffect : Sprite2D = player.sprite.duplicate()
	effect.add_child(spriteEffect)
	
	var tween : Tween= create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(effect,"modulate",Color(1,1,1,0.5),0.2) # can make the color as export value
	tween.chain().tween_callback(effect.queue_free)
	pass
