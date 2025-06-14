class_name PlayerAbilities extends Node

const BOOMERANG = preload("res://Player/boomerang.tscn")

var abilities : Array[String] = [
	"BOOMERANG","GRAPPLE","BOW", "BOMB"
]

var seleted_ability : int = 0
var player : Player 
var boomerang_instance : Boomerang = null

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
				print("Bow")
			3: 
				print("Bomb")
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
