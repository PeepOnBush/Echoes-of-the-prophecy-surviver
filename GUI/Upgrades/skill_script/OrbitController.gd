class_name OrbitController extends Node2D

const GEM_SCENE = preload("res://GUI/Upgrades/skill_scene/OrbitGem.tscn")

@export var rotation_speed: float = 4.0
@export var default_radius: float = 50.0

@onready var gem_container: Node2D = $GemContainer

var current_radius: float = 50.0
var gem_scale_bonus: float = 0.0 # Stores size upgrades
var is_active: bool = false

func _ready() -> void:
	visible = false
	set_physics_process(false)
	current_radius = default_radius

func _physics_process(delta: float) -> void:
	rotation += rotation_speed * delta # Rotates Self (Parent)

# --- CORE FUNCTIONALITY ---
func activate() -> void:
	if not is_active:
		is_active = true
		visible = true
		set_physics_process(true)
	
	add_gem()

func add_gem() -> void:
	var new_gem = GEM_SCENE.instantiate()
	gem_container.add_child(new_gem)
	
	# Apply existing upgrades to new gem
	new_gem.scale += Vector2(gem_scale_bonus, gem_scale_bonus)
	
	# Enable Hurtbox
	var hurtbox = new_gem.get_node_or_null("HurtBox")
	if hurtbox: hurtbox.set_deferred("monitoring", true)
	
	recalculate_positions()

func recalculate_positions() -> void:
	var gems = gem_container.get_children()
	var count = gems.size()
	if count == 0: return
	
	var spacing_angle = TAU / count
	
	for i in range(count):
		var gem = gems[i]
		# Position logic: Local 0,0 is center. We push out by radius.
		var target_pos = Vector2.RIGHT * current_radius
		gem.position = target_pos.rotated(spacing_angle * i)
		gem.rotation = gem.position.angle()

# --- UPGRADE FUNCTIONS (Call these from LevelUpSelection) ---

# 1. ARCANE EXPANSION (Radius Up)
func upgrade_radius(amount: float) -> void:
	current_radius += amount
	recalculate_positions() # Apply visual change instantly

# 2. MANA OVERLOAD (Size Up)
func upgrade_size(amount: float) -> void:
	gem_scale_bonus += amount
	
	# Apply to all existing gems
	for gem in gem_container.get_children():
		gem.scale += Vector2(amount, amount)

# 3. GRAVITATIONAL PULL (Speed Up)
func upgrade_speed(amount: float) -> void:
	rotation_speed += amount
