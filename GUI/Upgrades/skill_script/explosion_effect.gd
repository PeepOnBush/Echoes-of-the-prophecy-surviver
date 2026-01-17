class_name ExplosionEffect extends Node2D


@onready var explosion_sprite: Sprite2D = $ExplosionSprite
@onready var animation_player = $AnimationPlayer
@onready var audio_player = $AudioStreamPlayer2D

func _ready() -> void:
	explosion_sprite.visible = true
	explode()
	await get_tree().physics_frame
	# Connect animation finish to cleanup
	animation_player.animation_finished.connect(_on_animation_finished)
func explode() -> void:

	# A. Visuals
	explosion_sprite.visible = true # Show the fire
	animation_player.play("explode") # Play the fire animation
	
	# B. Camera Shake
	PlayerManager.shakeCamera(5.0)

func _on_animation_finished(_anim_name: String) -> void:
	queue_free()
