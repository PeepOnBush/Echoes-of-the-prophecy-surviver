extends CanvasLayer
signal menu_closed

const INVENTORY_SLOT = preload("res://GUI/pause_menu/inventory/inventory_slot.tscn")

@onready var chest_grid: GridContainer = %ChestGrid # Make sure to set these to Unique Names!
@onready var player_grid: GridContainer = %PlayerGrid

var chest_data: InventoryData
var player_data: InventoryData = PlayerManager.INVENTORY_DATA
var hovered_slot: Button = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	pass
func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("pause"):
		close_menu()
		get_viewport().set_input_as_handled()
	pass
func open_chest(_chest_data: InventoryData) -> void:
	chest_data = _chest_data
	
	# Pause game and show UI
	get_tree().paused = true
	visible = true
	
	refresh_ui()

func close_menu() -> void:
	visible = false
	get_tree().paused = false
	menu_closed.emit() # <--- Tell the world the UI closed!

func refresh_ui() -> void:
	# 1. Clear old slots
	for c in chest_grid.get_children(): c.queue_free()
	for c in player_grid.get_children(): c.queue_free()
	
	# 2. Populate Chest Grid (We pass the grid directly into the function now)
	for i in chest_data.slots.size():
		create_slot(chest_grid, chest_data, i)
		
	# 3. Populate Player Grid
	var p_slots = player_data.inventorySlots()
	for i in p_slots.size():
		create_slot(player_grid, player_data, i)
	pass

func create_slot(parent_grid: GridContainer, inv_data: InventoryData, index: int) -> void:
	var slot_ui = INVENTORY_SLOT.instantiate()
	
	# THE FIX: Add as a child FIRST so @onready variables (like texture_rect) load properly!
	parent_grid.add_child(slot_ui)
	
	# NOW we can safely set the data
	slot_ui.setSlotData(inv_data.slots[index])
	
	# Tag the slot with its exact memory location!
	slot_ui.set_meta("inv_data", inv_data)
	slot_ui.set_meta("slot_index", index)
	
	# Disable the "Use Item" click so you don't accidentally drink potions while managing chests
	if slot_ui.pressed.is_connected(slot_ui.itemPressed):
		slot_ui.pressed.disconnect(slot_ui.itemPressed)
		
	# Connect dragging signals
	slot_ui.button_up.connect(on_slot_dropped.bind(slot_ui))
	slot_ui.mouse_entered.connect(func(): hovered_slot = slot_ui)
	slot_ui.mouse_exited.connect(func(): if hovered_slot == slot_ui: hovered_slot = null)
	pass

func on_slot_dropped(dragged_slot: Button) -> void:
	# If we drop it on nothing, or on itself, do nothing
	if hovered_slot == null or hovered_slot == dragged_slot:
		return
		
	# Retrieve our Meta Tags
	var source_inv : InventoryData = dragged_slot.get_meta("inv_data")
	var source_index : int = dragged_slot.get_meta("slot_index")
	
	var target_inv : InventoryData = hovered_slot.get_meta("inv_data")
	var target_index : int = hovered_slot.get_meta("slot_index")
	
	# Swap the data directly in the Resource arrays!
	var temp = source_inv.slots[source_index]
	source_inv.slots[source_index] = target_inv.slots[target_index]
	target_inv.slots[target_index] = temp
	
	# Tell the rest of the game the inventories changed
	source_inv.emit_changed()
	if source_inv != target_inv:
		target_inv.emit_changed()
		
	# Redraw the UI
	refresh_ui()
	pass
