extends Sprite2D

const FRAME_COUNT : int  = 128

@onready var weapon_below: Sprite2D = $Sprite2DWeaponBelow
@onready var weapon_above: Sprite2D = $Sprite2DWeaponAbove

func _ready() -> void:
	PlayerManager.INVENTORY_DATA.equipment_changed.connect(onEquipmentChanged)
	pass

func _process(_delta: float ) -> void:
	weapon_below.frame = frame
	weapon_above.frame = frame + FRAME_COUNT 
	pass

func onEquipmentChanged() -> void:
	var equipment : Array[SlotData] = PlayerManager.INVENTORY_DATA.equipmentSlots()
	texture = equipment[0].item_data.sprite_texture
	weapon_below.texture = equipment[2].item_data.sprite_texture
	weapon_above.texture = equipment[2].item_data.sprite_texture
	pass
