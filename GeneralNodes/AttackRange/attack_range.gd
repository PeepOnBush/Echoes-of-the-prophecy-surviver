class_name AttackRange extends Area2D

var player_in_range: bool = false
var enemy_in_range : bool = false
func _ready() -> void:
	# Set collision layer/mask to only detect the Player layer
	# Assuming Player is Layer 1 or 2. Adjust these bits in Inspector if needed.
	monitorable = false # Enemies don't need to detect this area
	monitoring = true
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is Player: # Checks class_name Player
		player_in_range = true
	if body is Enemy:
		enemy_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
	if body is Enemy:
		enemy_in_range = false
