class_name ExplosiveBarrel extends StaticBody2D

@export var explosion_damage: int = 10
@export var knockback_force: float = 800.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var barrel_sprite: Sprite2D = $BarrelSprite
@onready var explosion_sprite: Sprite2D = $ExplosionSprite # Your fire sprite
@onready var blast_area: Area2D = $BlastArea # The renamed HurtBox
@onready var hit_box: HitBox = $Hitbox

var is_exploded: bool = false

func _ready() -> void:
	# Hide the explosion sprite initially
	if explosion_sprite:
		explosion_sprite.visible = false
	
	# Connect animation finish to cleanup
	animation_player.animation_finished.connect(_on_animation_finished)
	hit_box.Damaged.connect(_take_damage)

# 1. TRIGGER: This function is called by Arrows/Swords
func _take_damage(_hurt_box : HurtBox) -> void:
	explode()

# 2. ACTION: Boom
func explode() -> void:
	if is_exploded:
		return
	is_exploded = true
	
	# A. Visuals
	barrel_sprite.visible = false # Hide the wooden barrel
	explosion_sprite.visible = true # Show the fire
	animation_player.play("explode") # Play the fire animation
	
	# B. Camera Shake
	PlayerManager.shakeCamera(5.0)


func _on_animation_finished(_anim_name: String) -> void:
	queue_free()
