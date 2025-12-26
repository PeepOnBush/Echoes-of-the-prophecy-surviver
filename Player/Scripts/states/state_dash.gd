class_name StateDash extends State

@export var move_speed : float = 200
@export var effect_delay : float = 0.1
@export var dash_audio : AudioStream
@onready var idle: State = $"../idle"

var direction : Vector2 = Vector2.ZERO
var next_state : State = null
var effect_timer : float = 0

func Enter() -> void:
	# 1. Check Stamina
	if player.stamina < 25:
		# Go back to idle immediately. 
		# This triggers Exit(), so we need to handle that gracefully.
		state_machine.changeState(idle)
		return

	# 2. Spend Stamina
	player.stamina -= 25
	PlayerHud.updateStamina(player.stamina, player.max_stamina)
	
	# 3. Setup Dash
	player.invulnerable = true
	player.UpdateAnimation("dash")
	
	# 4. Connect Safely
	# Only connect if we aren't already connected
	if not player.animationPlayer.animation_finished.is_connected(onAnimationFinished):
		player.animationPlayer.animation_finished.connect(onAnimationFinished)
	
	direction = player.direction 
	if direction == Vector2.ZERO:
		direction = player.cardinal_direction 
		
	if dash_audio:
		player.audio.stream = dash_audio
		player.audio.play()
	effect_timer = 0

func Exit() -> void:
	# 1. REMOVED THE STAMINA CHECK
	# We must clean up NO MATTER WHAT.
	
	player.invulnerable = false
	
	# 2. Disconnect Safely
	# Only disconnect if we are actually connected
	if player.animationPlayer.animation_finished.is_connected(onAnimationFinished):
		player.animationPlayer.animation_finished.disconnect(onAnimationFinished)
	
	next_state = null

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
func onAnimationFinished(animation_name : String) -> void: 
	next_state = idle

func spawnEffect() -> void:
	var effect : Node2D = Node2D.new()
	player.get_parent().add_child(effect)
	effect.global_position = player.global_position - Vector2(0, 0.1)
	effect.modulate = Color(1.5,0.2,1.25,0.75)
	
	var spriteEffect : Sprite2D = player.sprite.duplicate()
	effect.add_child(spriteEffect)
	
	var tween : Tween= create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(effect,"modulate",Color(1,1,1,0.5),0.2) 
	tween.chain().tween_callback(effect.queue_free)
