class_name InventorySlotUI extends Button

@onready var texture_rect : TextureRect = $TextureRect
@onready var label : Label = $Label


var slot_data : SlotData : set = setSlotData
var click_pos : Vector2 = Vector2.ZERO
var dragging : bool = false
var drag_texture : Control 
var drag_threshold : float = 16.0


func _ready() -> void:
	texture_rect.texture = null
	label.text = ""
	focus_entered.connect(itemFocus)
	focus_exited.connect(itemUnFocus)
	pressed.connect(itemPressed)
	button_down.connect(onButtonDown)
	button_up.connect(onButtonUp)

func _process(_delta: float) -> void:
	if dragging == true:
		drag_texture.position = get_local_mouse_position() - Vector2(16,16)
		if outsideDragThreshold() == true:
			drag_texture.modulate.a = 0.5
		else:
			drag_texture.modulate.a = 0.0


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
	PauseMenu.focusedItemChanged(slot_data)
	pass
	
func itemUnFocus() -> void:
	PauseMenu.updateItemDescription("")
	pass

func itemPressed() -> void:
	if slot_data and outsideDragThreshold() == false:
		if slot_data.item_data:
			var item = slot_data.item_data
			
			if item is EquipableItemData:
				PlayerManager.INVENTORY_DATA.equipItem(slot_data)
				return
			
			var wasUsed = item.use()
			if wasUsed == false:
				return
			slot_data.quantity -= 1
			
			if slot_data == null:
				return
			label.text = str( slot_data.quantity )

func onButtonDown() -> void:
	click_pos = get_global_mouse_position()
	dragging = true
	drag_texture = texture_rect.duplicate()
	drag_texture.z_index = 10
	drag_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(drag_texture)
	pass

func onButtonUp() -> void:
	dragging = false
	if drag_texture:
		drag_texture.free()
	pass

func outsideDragThreshold() -> bool:
	if get_global_mouse_position().distance_to(click_pos) > drag_threshold:
		return true
	return false
