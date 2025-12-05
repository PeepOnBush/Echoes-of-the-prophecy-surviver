class_name Arrow extends Node2D

@export var move_speed : float = 300
@export var fire_audio : AudioStream

var move_dir : Vector2 = Vector2.RIGHT

@onready var hurt_box: HurtBox = $HurtBox
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sprite_2d_2: Sprite2D = $Sprite2D2
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
 
func _ready() -> void:
	hurt_box.did_damage.connect(onDidDamage)
	get_tree().create_timer(10.0).timeout.connect(onTimeOut)
	if fire_audio:
		audio_stream_player_2d.stream = fire_audio
		audio_stream_player_2d.play()
	pass

func _process(delta: float) -> void:
	# Move forward in the direction of rotation
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * move_speed * delta
	pass

func shoot(fire_dir : Vector2 ) -> void:
	move_dir = fire_dir
	rotateNode()
	pass

func rotateNode() -> void:
	var angle : float = move_dir.angle()
	sprite_2d.rotation = angle
	sprite_2d_2.rotation = angle
	hurt_box.rotation = angle
	pass


func onDidDamage() -> void:
	queue_free()
	pass

func onTimeOut() -> void:
	queue_free()
	pass
