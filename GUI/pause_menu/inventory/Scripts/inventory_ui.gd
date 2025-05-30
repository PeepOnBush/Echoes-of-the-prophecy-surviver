class_name InventoryUI extends Control

const INVENTORY_SLOT = preload("res://GUI/pause_menu/inventory/inventory_slot.tscn")

var focusIndex: int = 0
var hovered_item : InventorySlotUI

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
		connectItemSignals(slot)
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

func connectItemSignals(item : InventorySlotUI) -> void:
	if not item.button_up.is_connected(onItemDrop):
		item.button_up.connect(onItemDrop.bind(item))
	
	if not item.mouse_entered.is_connected(onItemMouseEntered):
		item.mouse_entered.connect(onItemMouseEntered.bind(item))
	
	if not item.mouse_exited.is_connected(onItemMouseExited):
		item.mouse_exited.connect(onItemMouseExited)
	pass

func onItemDrop(item : InventorySlotUI) -> void:
	if item == null or item == hovered_item or hovered_item == null:
		return
	data.swapItemByIndex(item.get_index(), hovered_item.get_index())
	updateInventory(false)
	pass

func onItemMouseEntered(item : InventorySlotUI) -> void:
	hovered_item = item
	pass

func onItemMouseExited() -> void:
	hovered_item = null
	pass
