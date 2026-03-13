extends Node2D

func _ready() -> void:
	visible = false 
	
	print("--- SPAWN CHECK ---")
	print("My Name is: ", self.name)
	print("LevelManager is looking for: ", LevelManager.target_transition)
	
	if self.name == LevelManager.target_transition:
		# THE FIX: Wait one physics frame so global_position calculates correctly
		call_deferred("teleport_player")
		
	elif PlayerManager.playerSpawned == false:
		call_deferred("teleport_player")
		PlayerManager.playerSpawned = true
	else:
		print("NO MATCH. Ignoring this spawn point.")

func teleport_player() -> void:
	print("Teleporting Player to TRUE position: ", global_position)
	PlayerManager.set_player_position(global_position)
