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
	if dragging == true and is_instance_valid(drag_texture):
		# 1. Find the target position (Center of the mouse)
		# Using drag_texture.size / 2.0 is safer than hardcoding Vector2(16,16)
		var target_pos = get_local_mouse_position() - (drag_texture.size / 2.0)
		
		# 2. JUICE: The Smooth Chase
		# Lerp moves it a percentage of the distance every frame (15.0 is the "tightness" of the spring)
		drag_texture.position = drag_texture.position.lerp(target_pos, 15.0 * _delta)
		
		# 3. JUICE: The Velocity Tilt
		# Calculate how far behind the mouse the texture is on the X axis, and tilt it!
		var distance_behind = target_pos.x - drag_texture.position.x
		# We multiply by 0.03 to keep the rotation subtle, and lerp it so it doesn't snap.
		drag_texture.rotation = lerp_angle(drag_texture.rotation, distance_behind * 0.03, 20.0 * _delta)
		
		# 4. Your original drag threshold logic
		if outsideDragThreshold() == true:
			drag_texture.modulate.a = 0.85 # Slightly more visible than 0.5 so it pops!
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
	#PauseMenu.updateItemDescription("")
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
	
	# Start the drag texture exactly where the slot texture is
	drag_texture.position = texture_rect.position 
	# Reset pivot so the rotation and scaling happens from the center of the icon
	drag_texture.pivot_offset = drag_texture.size / 2.0 
	
	add_child(drag_texture)
	
	# --- JUICE: The "Spring Pop" ---
	# Start it small...
	drag_texture.scale = Vector2(0.5, 0.5) 
	var tween = create_tween()
	# TRANS_SPRING is the greatest thing Godot 4 added. It creates a natural bouncy elastic effect.
	tween.set_trans(Tween.TRANS_SPRING) 
	tween.set_ease(Tween.EASE_OUT)
	# Tween it slightly larger than normal (1.2x scale) over 0.3 seconds
	tween.tween_property(drag_texture, "scale", Vector2(1.2, 1.2), 0.3)
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
