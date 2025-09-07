class_name stateGrapple extends State


@onready var idle: stateIdle = $"../idle"
@onready var grapple_hook: Node2D = %GrappleHook
@onready var nine_patch_rect: NinePatchRect = $"../../GrappleHook/NinePatchRect"
@onready var chain_audio_player : AudioStreamPlayer2D = $"../../GrappleHook/AudioStreamPlayer2D"
@onready var grapple_ray_cast_2d: RayCast2D = %GrappleRayCast2D
@onready var grapple_hurt_box: HurtBox = %GrappleHurtBox

@export var grapple_distance : float = 100.0
@export var grapple_speed : float = 200.0
@export_group("audio_sfx")
@export var grapple_fire_audio : AudioStream
@export var grapple_stick_audio : AudioStream
@export var grapple_bounce_audio : AudioStream

var collision_distance : float
var collision_type : int = 0 # 0 if no collision, 1 if hit wall, 2 if hit grapple_point
var nine_patch_size : float = 25.0

var tween : Tween

var next_state : State = null

var positions : Array[Vector3] = [
	Vector3(0.0, -20.0, 180.0),#UP
	Vector3(0.0, -10.0, 0.0),#DOWN
	Vector3(-10.0, -15.0, 90.0),#LEFT
	Vector3(10.0, -15.0, -90.0),#RIGHT
]

var pos_map : Dictionary = {
	Vector2.UP : 0,
	Vector2.DOWN : 1,
	Vector2.LEFT : 2,
	Vector2.RIGHT : 3,
}

## What happen when the player enter this state ?
func Enter() -> void:
	player.UpdateAnimation("idle")
	grapple_hook.visible = true
	grapple_hurt_box.monitoring = true
	setGrapplePosition()
	RayCastDectection()
	shootGrapple()
	chain_audio_player.play()
	playAudio(grapple_fire_audio)
	pass

func init() -> void:
	grapple_hook.visible = false
	grapple_ray_cast_2d.enabled = false
	grapple_ray_cast_2d.target_position.y = grapple_distance
	grapple_hurt_box.monitoring = false
	pass

## What happen when the player exit this state ?
func Exit() -> void:
	next_state = null
	grapple_hook.visible = false
	grapple_hurt_box.monitoring = false
	chain_audio_player.stop()
	tween.kill()
	nine_patch_rect.size.y = nine_patch_size
	pass
## What happen when the _process update in this state ?
func Process(_delta : float) -> State:
	player.velocity = Vector2.ZERO
	return next_state
	
func Physics(_delta : float) -> State:
	
	return null


func HandleInput( _event: InputEvent) -> State:
	return null
	

func playAudio(audio : AudioStream) -> void:
	player.audio.stream = audio
	player.audio.play()
	pass


func setGrapplePosition() -> void:
	var new_pos : Vector3 = positions[
		pos_map[player.cardinal_direction]
	]
	grapple_hook.position = Vector2(new_pos.x, new_pos.y)
	grapple_hook.rotation_degrees = new_pos.z
	if player.cardinal_direction == Vector2.UP:
		grapple_hook.show_behind_parent = true
	else:
		grapple_hook.show_behind_parent = false
	pass

func RayCastDectection() -> void:
	collision_type = 0
	collision_distance = grapple_distance
	grapple_ray_cast_2d.set_collision_mask_value( 5 ,false)
	grapple_ray_cast_2d.set_collision_mask_value( 6 ,true )
	grapple_ray_cast_2d.force_raycast_update()
	if grapple_ray_cast_2d.is_colliding():
		collision_type = 2
		collision_distance = grapple_ray_cast_2d.get_collision_point().distance_to( player.global_position )
		return
	grapple_ray_cast_2d.set_collision_mask_value( 5 ,true)
	grapple_ray_cast_2d.set_collision_mask_value( 6 ,false )
	grapple_ray_cast_2d.force_raycast_update()
	if grapple_ray_cast_2d.is_colliding():
		collision_type = 1
		collision_distance = grapple_ray_cast_2d.get_collision_point().distance_to( player.global_position )
		return
	pass

func shootGrapple() -> void:
	if tween:
		tween.kill()
	
	var tween_duration : float = collision_distance / grapple_speed
	tween = create_tween()
	tween.tween_property(
		nine_patch_rect, "size",
		Vector2(nine_patch_rect.size.x,collision_distance),
		tween_duration
	)
	if collision_type == 2:
		tween.tween_callback(grapplePlayer)
	else :
		tween.tween_callback(returnGrapple)
	pass

func grapplePlayer() -> void:
	if tween:
		tween.kill()
	playAudio(grapple_stick_audio)
	player.set_collision_mask_value( 4,false )
	var tween_duration : float = collision_distance / grapple_speed
	tween = create_tween()
	tween.tween_property(
		nine_patch_rect, "size",
		Vector2(nine_patch_rect.size.x,nine_patch_size),
		tween_duration
	)
	var player_target : Vector2 = player.global_position 
	player_target += (player.cardinal_direction * collision_distance)
	player_target -= player.cardinal_direction * nine_patch_size
	tween.parallel().tween_property(
		player,'global_position',
		player_target,
		tween_duration
	)
	player.make_invulnerable(tween_duration)
	tween.tween_callback(grappleFinish) 
	pass

func returnGrapple() -> void:
	if tween:
		tween.kill()
	
	if collision_type > 0:
		playAudio(grapple_bounce_audio)
	
	var tween_duration : float = collision_distance / grapple_speed
	tween = create_tween()
	tween.tween_property(
		nine_patch_rect, "size",
		Vector2(nine_patch_rect.size.x,nine_patch_size),
		tween_duration
	)
	tween.tween_callback( grappleFinish)
	pass

func grappleFinish() -> void:
	player.set_collision_mask_value(4,true)
	next_state = idle
	pass
