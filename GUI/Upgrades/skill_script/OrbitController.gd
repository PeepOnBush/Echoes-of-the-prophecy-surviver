class_name OrbitController extends Node2D

@export var rotation_speed: float = 4.0 # How fast it spins
@onready var hurt_box: HurtBox = $Visuals/HurtBox
var is_active: bool = false

func _ready() -> void:
	# 1. Start completely disabled
	visible = false
	set_physics_process(false) # Stop spinning to save CPU
	
	# Wait for first frame to ensure HurtBox is ready before disabling
	await get_tree().process_frame
	if hurt_box:
		hurt_box.set_deferred("monitoring", false)
	pass

func _physics_process(delta: float) -> void:
	rotation += rotation_speed * delta

func activate() -> void:
	if is_active:
		return # Already active? Maybe upgrade stats instead (logic for later)
	
	is_active = true
	visible = true
	set_physics_process(true) # Start spinning
	
	if hurt_box:
		hurt_box.set_deferred("monitoring", true)
