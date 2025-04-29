class_name EquipableItemData extends ItemData

enum Type {WEAPON, ARMOR, AMULET, RING }
@export var type : Type = Type.WEAPON
@export var modifiers : Array[EquipableItemModifier] 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
