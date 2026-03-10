class_name BossCorpse extends Node2D

# Adjust this path based on your tree!
@onready var scene_change_result: DialogResultCommon =  $DialogInteraction/DialogChoice/DialogBranch/Do_CHANGE_SCENE

func setup(corpse_sprite: Sprite2D, destination: String,boss_scale: Vector2) -> void:
	# 1. Remove the placeholder sprite from the Corpse scene
	if has_node("Sprite2D"):
		$Sprite2D.queue_free()
	
	# 2. Attach the dead boss's actual sprite
	# It already has the correct texture, hframes, vframes, and is stuck on the last frame!
	add_child(corpse_sprite)
	# Ensure the sprite is centered and visible
	corpse_sprite.position = Vector2.ZERO
	corpse_sprite.scale = boss_scale # <--- APPLY THE SCALE HERE
	corpse_sprite.visible = true
	# 3. Set the destination for the dialog
	if scene_change_result:
		scene_change_result.target_scene = destination
