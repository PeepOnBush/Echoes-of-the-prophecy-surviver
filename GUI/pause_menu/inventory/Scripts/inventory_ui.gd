class_name InventoryUI extends Control

const INVENTORY_SLOT = preload("res://GUI/pause_menu/inventory/inventory_slot.tscn")

var focusIndex: int = 0

@export var data : InventoryData 


func _ready() -> void:
	PauseMenu.shown.connect(updateInventory)
	PauseMenu.hidden.connect(clearInventory)
	clearInventory()
	data.changed.connect(onInventoryChanged)
	pass
	
func clearInventory() -> void:
	for c in get_children():
		c.queue_free()

func updateInventory() -> void:
	clearInventory()
	for s in data.slots:
		var newSlot = INVENTORY_SLOT.instantiate()
		add_child(newSlot)
		newSlot.slot_data = s
		newSlot.focus_entered.connect(itemFocus)
	
	await get_tree().process_frame
	get_child(focusIndex).grab_focus()


func itemFocus() -> void:
	for i in get_child_count():
		if get_child(i).has_focus():
			focusIndex = i 
			return

func onInventoryChanged() -> void: 
	clearInventory()
	updateInventory()
	
