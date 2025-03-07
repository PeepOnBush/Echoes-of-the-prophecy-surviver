@tool
extends NPCBehavior

const DIRECTION = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

@export var wander_range : int = 2 : set = setWanderRange
@export var wander_speed : float = 30
@export var wander_duration : float = 1.0
@export var idle_duration : float = 1.0

var original_position : Vector2

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	super()
	$CollisionShape2D.queue_free()
	original_position = npc.global_position

func _process(_delta : float) -> void:
	if Engine.is_editor_hint():
		return
	if abs( global_position.distance_to( original_position) ) > wander_range * 32:
		npc.velocity *= -1
		npc.direction *= -1
		npc.updateDirection(global_position + npc.direction)
		npc.updateAnimation()

func start() -> void:
	#IDLE PHASE
	if npc.doBehavior == false:
		return
	npc.state = "idle"
	npc.velocity = Vector2.ZERO
	npc.updateAnimation()
	await get_tree().create_timer(randf() * idle_duration + idle_duration * 0.5).timeout
	if npc.doBehavior == false:
		return
	#WALK PHASE
	npc.state = "walk"
	var _dir : Vector2 = DIRECTION[randi_range(0,3)]
	npc.direction = _dir
	npc.velocity = wander_speed * _dir
	npc.updateDirection( global_position + _dir)
	npc.updateAnimation()
	await get_tree().create_timer(randf() * wander_duration + wander_duration * 0.5).timeout
	#LOOP
	if npc.doBehavior == false:
		return
	start()
	pass

func setWanderRange( v : int ) -> void:
	wander_range = v
	$CollisionShape2D.shape.radius = v * 32.0
	pass
 
