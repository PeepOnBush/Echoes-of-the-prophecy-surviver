class_name PlayerAbilities extends Node

const BOOMERANG = preload("res://Player/boomerang.tscn")
const BOMB = preload("res://Interactables/Bomb/bomb.tscn")
var abilities : Array[String] = [
	"","","", "" #BOOMERANG, GRAPPLE, ARROW, BOMB
]
var selected_ability : int = 0
var player : Player 
var boomerang_instance : Boomerang = null
var noMoreArrow : AudioStream = preload("res://GUI/shop_menu/Audio/error.wav")

@onready var state_machine: playerStateMachine = $"../StateMachine"
@onready var idle: stateIdle = $"../StateMachine/idle"
@onready var walk: stateWalking = $"../StateMachine/walk"
@onready var carry: StateCarry = $"../StateMachine/Carry"
@onready var lift: StateLift = $"../StateMachine/Lift"
@onready var shoot: StateShoot = $"../StateMachine/Shoot"
@onready var grapple: stateGrapple = $"../StateMachine/Grapple"
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../Audio/AudioStreamPlayer2D"
func _ready() -> void:
	player = PlayerManager.player
	PlayerHud.update_arrow_count(player.arrow_count)
	PlayerHud.update_bomb_count(player.bomb_count)
	setupAbilities()
	SaveManager.game_loaded.connect(onGameLoaded)
	PlayerManager.INVENTORY_DATA.ability_acquired.connect(onAbilityAcquired)

func setupAbilities( select_index : int = 0) -> void:
	#update pause menu
	PauseMenu.updateAbilityItems(abilities)
	#update player HUD
	PlayerHud.updateAbilityItem(abilities)
	selected_ability = select_index - 1
	toggleAbility()
	pass

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ability"):
		match selected_ability:
			0:
				boomerangAbility()
			1:
				grappleAbility()
			2:
				bowAbility()
			3: 
				bombAbility()
	elif event.is_action_pressed("switch_ability"):
		toggleAbility()
		
	pass

func toggleAbility() -> void:
	if abilities.count("") == abilities.size():
		return
	selected_ability = wrapi(selected_ability+1, 0 ,4)
	while abilities[selected_ability] == "":
		selected_ability = wrapi(selected_ability+1, 0 ,4)
	PlayerHud.updateAbilityUI(selected_ability)
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

func bowAbility() -> void:
	if player.arrow_count <= 0 :
		audio_stream_player_2d.stream = noMoreArrow
		audio_stream_player_2d.play()
		return
	elif state_machine.currentState == idle or state_machine.currentState == walk :
		player.arrow_count -= 1
		player.state_Machine.changeState(shoot)
		pass
	pass

func grappleAbility() -> void:
	if state_machine.currentState == idle or state_machine.currentState == walk :
		player.state_Machine.changeState(grapple)
		pass
	pass

func onGameLoaded() -> void:
	var new_abilities = SaveManager.currentSave.abilities
	print(new_abilities)
	abilities.clear()
	for i in new_abilities:
		abilities.append(i)
	pass

func onAbilityAcquired(_ability : AbilityItemData) -> void:
	print("give ability", _ability.type)
	 #BOOMERANG, GRAPPLE, ARROW, BOMB
	match _ability.type:
		_ability.Type.BOOMERANG:
			abilities[0] = "BOOMERANG"
		_ability.Type.GRAPPLE:
			abilities[1] = "GRAPPLE"
		_ability.Type.ARROW:
			abilities[2] = "ARROW"
		_ability.Type.BOMB:
			abilities[3] = "BOMB"
	setupAbilities(selected_ability)
	pass
