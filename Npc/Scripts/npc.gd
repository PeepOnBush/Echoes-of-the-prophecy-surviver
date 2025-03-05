@tool
@icon ("res://Npc/Icons/npc.svg" )
class_name NPC extends CharacterBody2D

signal do_behavior_enabled 

var state : String = "idle"
var direction : Vector2 = Vector2.DOWN
var directionName : String = "down"
var doBehavior : bool = true

@export var npc_resource : NPCResource : set = setNpcResource

@onready var sprite : Sprite2D = $Sprite2D
@onready var animation : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	setupNpc()
	if Engine.is_editor_hint():
		return 
	gatherInteractables()
	do_behavior_enabled.emit()
	pass

func _physics_process(_delta : float) -> void:
	move_and_slide()

func gatherInteractables() -> void:
	for c in get_children():
		if c is DialogInteraction:
			c.player_interacted.connect( onPlayerInteract)
			c.finished.connect( onInteractFinished)

func onPlayerInteract() -> void:
	updateDirection(PlayerManager.player.global_position)
	state = "idle"
	velocity = Vector2.ZERO
	updateAnimation()
	doBehavior = false
	pass

func onInteractFinished() -> void:
	state = "idle"
	updateAnimation()
	doBehavior = true
	do_behavior_enabled.emit()
	pass

func updateAnimation() -> void:
	animation.play( state + "_" + directionName)

func updateDirection(targetPosition : Vector2) -> void:
	direction = global_position.direction_to(targetPosition)
	updateDirectionName()
	if directionName == "side" and direction.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func updateDirectionName() -> void:
	var threshold : float = 0.45
	if direction.y < -threshold:
		directionName = "up"
	elif  direction.y > threshold:
		directionName = "down"
	elif direction.x > threshold || direction.x < -threshold:
		directionName = "side"

func setupNpc() -> void:
	if npc_resource:
		if sprite:
			sprite.texture = npc_resource.sprite
	pass

func setNpcResource( _npc : NPCResource) -> void:
	npc_resource = _npc
	setupNpc()
