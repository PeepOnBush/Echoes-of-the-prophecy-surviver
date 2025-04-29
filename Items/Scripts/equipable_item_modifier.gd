class_name EquipableItemModifier extends Resource

enum Type { HEALTH, ATTACK, DEFENSE , SPEED}
@export var type : Type = Type.HEALTH
@export var value : int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
