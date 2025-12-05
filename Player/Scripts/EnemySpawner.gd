extends Area2D

@export var enemy_scenes: Array[PackedScene]
@export var spawn_radius: float = 400.0  # <--- Set this number in the Inspector!

@onready var spawn_timer: Timer = $Timer
var time_elapsed : float = 0.0

func _ready() -> void:
	spawn_timer.timeout.connect(_on_timer_timeout)



func _on_timer_timeout() -> void:
	if enemy_scenes.size() == 0:
		return
		
	# 1. Pick random enemy
	var random_enemy_scene = enemy_scenes.pick_random()
	var enemy_instance = random_enemy_scene.instantiate()
	
	# 2. Math: Pick random angle (0 to 360)
	var random_angle = randf() * TAU 
	
	# 3. Create vector: Go 'spawn_radius' distance in that direction
	var spawn_vector = Vector2(spawn_radius, 0).rotated(random_angle)
	
	# 4. Add to Level (Root)
	var level_root = get_tree().current_scene
	level_root.add_child(enemy_instance)
	
	# 5. Set Position
	# global_position here is the Player's position (since Spawner is child of Player)
	enemy_instance.global_position = global_position + spawn_vector
