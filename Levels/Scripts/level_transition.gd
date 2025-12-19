@tool
class_name LevelTransition extends Area2D

signal scene_entered

enum SIDE { LEFT, RIGHT, TOP, BOTTOM }

var is_dynamic_spawn : bool = false


@export_file( "*.tscn" ) var level 

@export var target_transition_area : String = "LevelTransition"

@export var center_player : bool = false

@export_category("Collision Area Setting")

@export_range(1,12,1, "or_greater") var size : int = 2:
	set( _v ) :
		size = _v
		# Only update if inside tree or if we can find the node immediately
		if is_inside_tree() or get_node_or_null("CollisionShape2D"):
			_update_area()

@export var side : SIDE = SIDE.LEFT :
	set( _v ) :
		side = _v
		_update_area()


@export var snap_to_grid : bool = false:
	set(_v):
		_snap_to_grid()


@onready var collision_shape : CollisionShape2D = $CollisionShape2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_area()
	if Engine.is_editor_hint():
		return
	monitoring = false
	_place_player()
	
	if is_dynamic_spawn == false:
		await LevelManager.level_loaded
	monitoring = true
	
	if self.has_signal("body_entered"): 
		if not body_entered.is_connected(_player_entered):
			body_entered.connect(_player_entered)
	
	pass # Replace with function body.


func _player_entered( _p : Node2D) -> void:
	LevelManager.load_new_level(level,target_transition_area,get_offset())
	pass
 
func _place_player() -> void:
	if name != LevelManager.target_transition:
		return
	PlayerManager.set_player_position( global_position + LevelManager.position_offset )
	scene_entered.emit()

func get_offset() -> Vector2:
	var offset : Vector2 = Vector2.ZERO
	var player_pos = PlayerManager.player.global_position
	
	if side == SIDE.LEFT or side == SIDE.RIGHT :
		if center_player == true:
			offset.y = 0
		else:
			offset.y = player_pos.y - global_position.y
		offset.x = 16
		if side == SIDE.LEFT :
			offset.x *= -1
	else : 
		if center_player == true:
			offset.x = 0
		else:
			offset.x = player_pos.x - global_position.x
		offset.y = 16
		if side == SIDE.TOP :
			offset.y *= -1

	return offset



func _update_area() -> void:
	# Ensure we have the reference
	if collision_shape == null:
		collision_shape = get_node_or_null("CollisionShape2D")
	
	if collision_shape == null:
		return # Safety exit if called too early
	var new_rect : Vector2 = Vector2(32,32)
	var new_position : Vector2 = Vector2.ZERO
	if side == SIDE.TOP:
		new_rect.x *= size
		new_position.y -= 16
	elif side == SIDE.BOTTOM:
		new_rect.x *= size
		new_position.y += 16
	elif side == SIDE.LEFT:
		new_rect.y *= size
		new_position.x -= 16
	elif side == SIDE.RIGHT:
		new_rect.y *= size
		new_position.x += 16
	
	if collision_shape == null :
		collision_shape = get_node("CollisionShape2D")
		
	collision_shape.shape.size = new_rect
	collision_shape.position = new_position

func _snap_to_grid() -> void:
	position.x = round(position.x / 16) * 16
	position.y = round(position.y / 16) * 16
	
