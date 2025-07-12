class_name PlayerAbilities extends Node

const BOOMERANG = preload("res://Player/boomerang.tscn")
const BOMB = preload("res://Interactables/Bomb/bomb.tscn")
var abilities : Array[String] = [
	"BOOMERANG","GRAPPLE","BOW", "BOMB"
]
var seleted_ability : int = 0
var player : Player 
var boomerang_instance : Boomerang = null
var noMoreArrow : AudioStream = preload("res://GUI/shop_menu/Audio/error.wav")

@onready var state_machine: playerStateMachine = $"../StateMachine"
@onready var idle: stateIdle = $"../StateMachine/idle"
@onready var walk: stateWalking = $"../StateMachine/walk"
@onready var carry: StateCarry = $"../StateMachine/Carry"
@onready var lift: StateLift = $"../StateMachine/Lift"
@onready var shoot: StateShoot = $"../StateMachine/Shoot"
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../Audio/AudioStreamPlayer2D"
func _ready() -> void:
	player = PlayerManager.player
	PlayerHud.update_arrow_count(player.arrow_count)
	PlayerHud.update_bomb_count(player.bomb_count)


func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ability"):
		match seleted_ability:
			0:
				boomerangAbility()
			1:
				print("Grapple hook")
			2:
				bow_ability()
			3: 
				bombAbility()
	elif event.is_action_pressed("switch_ability"):
		toggleAbility()
		
	pass

func toggleAbility() -> void:
	seleted_ability = wrapi(seleted_ability+1, 0 ,4)
	PlayerHud.updateAbilityUI(seleted_ability)
	pass

func boomerangAbility() -> void:
	if boomerang_instance != null:
		return
	
	var _b = BOOMERANG.instantiate() as Boomerang
	player.add_sibling(_b)
	_b.global_position = player.global_position
	
	var throwDirection = player.direction
	if throwDirection == Vector2.ZERO:
		throwDirection = player.cardinal_direction
	
	_b.throw(throwDirection)
	boomerang_instance = _b
	pass

func bombAbility() -> void:
	if player.bomb_count <= 0:
		return
	elif state_machine.currentState == idle or state_machine.currentState == walk :
		player.bomb_count -= 1
		lift.start_anim_late = true
		var bomb : Node2D = BOMB.instantiate()
		player.add_sibling(bomb)
		bomb.global_position = player.global_position
		PlayerManager.interact_handled = false
		var throwable : ThrowableBomb = bomb.find_child("Throwable")
		throwable.playerInteract()
		pass
	pass

func bow_ability() -> void:
	if player.arrow_count <= 0 :
		audio_stream_player_2d.stream = noMoreArrow
		audio_stream_player_2d.play()
		return
	elif state_machine.currentState == idle or state_machine.currentState == walk :
		player.arrow_count -= 1
		player.state_Machine.changeState(shoot)
		pass
	pass
