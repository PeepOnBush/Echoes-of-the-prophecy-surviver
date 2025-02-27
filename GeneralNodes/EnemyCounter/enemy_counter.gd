class_name EnemyCounter extends Node2D

signal level_cleared

func _ready() -> void:
	child_exiting_tree.connect(onEnemyDestroyed)
	pass

func onEnemyDestroyed(e : Node2D) -> void:
	if e is Enemy:
		if enemyCount() <= 1:
			level_cleared.emit()
			print("level cleared")
	pass

func enemyCount() -> int:
	var count : int = 0
	for c in get_children():
		if c is Enemy:
			count +=1
	return count
