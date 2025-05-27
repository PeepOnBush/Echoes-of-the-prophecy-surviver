class_name InventoryUI extends Control

const INVENTORY_SLOT = preload("res://GUI/pause_menu/inventory/inventory_slot.tscn")

var focusIndex: int = 0

@export var data : InventoryData 

@onready var inventory_slot_armor: InventorySlotUI = %InventorySlot_Armor
@onready var inventory_slot_amulet: InventorySlotUI = %InventorySlot_Amulet
@onready var inventory_slot_weapon: InventorySlotUI = %InventorySlot_Weapon
@onready var inventory_slot_ring_1: InventorySlotUI = %InventorySlot_Ring_1
@onready var inventory_slot_shield_2: InventorySlotUI = %InventorySlot_Shield2
@onready var inventory_slot_tool: InventorySlotUI = %InventorySlot_Tool


func _ready() -> void:
	PauseMenu.shown.connect(updateInventory)
	PauseMenu.hidden.connect(clearInventory)
	clearInventory()
	data.changed.connect(onInventoryChanged)
	data.equipment_changed.connect(onInventoryChanged)
	pass
	
func clearInventory() -> void:
	for c in get_children():
		c.setSlotData(null)

func updateInventory( apply_focus : bool = true) -> void:
	clearInventory()
	
	var inventorySlots : Array[SlotData] = data.inventorySlots()
	
	for i in inventorySlots.size():
		var slot : InventorySlotUI = get_child(i)
		slot.setSlotData(inventorySlots[i])
	
	#update equipment slot
	var e_slot : Array[SlotData] = data.equipmentSlots()
	inventory_slot_armor.setSlotData(e_slot[0])
	inventory_slot_amulet.setSlotData(e_slot[1])
	inventory_slot_weapon.setSlotData(e_slot[2])
	inventory_slot_ring_1.setSlotData(e_slot[3])
	inventory_slot_shield_2.setSlotData(e_slot[4])
	inventory_slot_tool.setSlotData(e_slot[5])
	if apply_focus:
		get_child(0).grab_focus()


func itemFocus() -> void:
	for i in get_child_count():
		if get_child(i).has_focus():
			focusIndex = i 
			return

func onInventoryChanged() -> void: 
	updateInventory(false)
	
