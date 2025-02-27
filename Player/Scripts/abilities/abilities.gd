class_name PlayerAbilities extends Node

const BOOMERANG = preload("res://Player/boomerang.tscn")

enum abilities {BOOMERANG,GRAPPLE}

var seleted_ability = abilities.BOOMERANG
var player : Player 
var boomerang_instance : Boomerang = null

func _ready() -> void:
	player = PlayerManager.player


func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ability"):
		if seleted_ability == abilities.BOOMERANG:
			boomerangAbility()
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
