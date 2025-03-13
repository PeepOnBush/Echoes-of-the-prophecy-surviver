extends Area2D

@export var cloud_scene: PackedScene = preload("res://Menu/clouds.tscn")  # Link to your Cloud scene
@export var spawn_interval: float = 2.0  # Time between cloud spawns in seconds

var timer: float = 0.0
var shape_extents: Vector2  # To store the collision shape's extents

# Reference to the CollisionShape2D node
@onready var collision_shape = $CollisionShape2D

func _ready():
	# Ensure the CollisionShape2D exists and has a RectangleShape2D
	if collision_shape and collision_shape.shape is RectangleShape2D:
		shape_extents = collision_shape.shape.extents
	else:
		print("Error: CollisionShape2D not found or shape is not a RectangleShape2D")
		shape_extents = Vector2(50, 50)  # Fallback value

func _process(delta):
	timer += delta
	if timer >= spawn_interval:
		spawn_cloud()
		timer = 0.0

func spawn_cloud():
	var cloud_instance = cloud_scene.instantiate()
	# Calculate random position within the collision shape's bounds
	var spawn_pos = Vector2(
		randf_range(-shape_extents.x, shape_extents.x),
		randf_range(-shape_extents.y, shape_extents.y)
	)
	# Adjust for the position of the Area2D
	cloud_instance.position = global_position + spawn_pos
	# Add the cloud to the parent node
	get_parent().add_child(cloud_instance)
	print("Cloud spawned at: ", cloud_instance.global_position)  # Debug output
