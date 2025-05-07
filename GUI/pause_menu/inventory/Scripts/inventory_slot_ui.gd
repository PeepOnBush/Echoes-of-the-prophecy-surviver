class_name InventorySlotUI extends Button

var slot_data : SlotData : set = setSlotData

@onready var texture_rect : TextureRect = $TextureRect
@onready var label : Label = $Label

func _ready() -> void:
	texture_rect.texture = null
	label.text = ""
	focus_entered.connect(itemFocus)
	focus_exited.connect(itemUnFocus)
	pressed.connect(itemPressed)

func setSlotData( value : SlotData) -> void:
	slot_data = value
	if slot_data == null:
		texture_rect.texture = null
		label.text = ""
		return
	texture_rect.texture = slot_data.item_data.texture
	if slot_data.item_data is EquipableItemData:
		label.text = ""
	else:
		label.text = str(slot_data.quantity)

func itemFocus() -> void:
	if slot_data != null:
		if slot_data.item_data != null:
			PauseMenu.updateItemDescription(slot_data.item_data.description)
	
	pass
	
func itemUnFocus() -> void:
	PauseMenu.updateItemDescription("")
	pass

func itemPressed() -> void:
	if slot_data:
		if slot_data.item_data:
			var wasUsed = slot_data.item_data.use()
			if wasUsed == false:
				return
			slot_data.quantity -= 1
			label.text = str(slot_data.quantity) 
