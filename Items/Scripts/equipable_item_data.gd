class_name EquipableItemData extends ItemData

enum Type {WEAPON, ARMOR, AMULET, RING, TOOL, SHIELD }
@export var type : Type = Type.WEAPON
@export var modifiers : Array[EquipableItemModifier] 
