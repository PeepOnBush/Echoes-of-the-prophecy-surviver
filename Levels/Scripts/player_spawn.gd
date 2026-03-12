extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false 
	# If the LevelManager says THIS is the target node, spawn the player here!
	if self.name == LevelManager.target_transition:
		PlayerManager.set_player_position(global_position)
		pass
	# Fallback for the very first time the game boots up
	elif PlayerManager.playerSpawned == false:
		PlayerManager.set_player_position(global_position)
		PlayerManager.playerSpawned = true
		pass
	pass
