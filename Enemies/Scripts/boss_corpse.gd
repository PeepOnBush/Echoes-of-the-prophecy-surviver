class_name BossCorpse extends Node2D

# We remove the @onready path completely because it breaks too easily.
var scene_change_result: DialogResultCommon = null

func _ready() -> void:
	# Search the entire scene tree for the specific DialogResult node
	find_scene_changer(self)

# Recursive function to find the exact DialogResult we need
func find_scene_changer(current_node: Node) -> void:
	for child in current_node.get_children():
		if child is DialogResultCommon and child.action_type == DialogResultCommon.ActionType.CHANGE_SCENE:
			scene_change_result = child
			return # Found it! Stop searching.
		if child.get_child_count() > 0:
			find_scene_changer(child)

func setup(corpse_sprite: Sprite2D, destination: String, boss_scale: Vector2) -> void:
	# 1. Ensure we found the result node before the Boss tries to overwrite it
	if scene_change_result == null:
		find_scene_changer(self)
		
	# 2. Visual Handoff
	if has_node("Sprite2D"):
		$Sprite2D.queue_free()
	
	add_child(corpse_sprite)
	corpse_sprite.position = Vector2.ZERO
	corpse_sprite.scale = boss_scale
	corpse_sprite.visible = true
	
	# 3. Data Handoff (The crucial part)
	if scene_change_result:
		scene_change_result.target_scene = destination
		print("Corpse Successfully updated destination to: ", destination)
	else:
		printerr("CRITICAL ERROR: BossCorpse could not find a DialogResultCommon set to CHANGE_SCENE!")
