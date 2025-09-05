class_name  InventoryData extends Resource

@warning_ignore("unused_signal")
signal equipment_changed
signal ability_acquired(ability : AbilityItemData )

@export var slots : Array[ SlotData ]
var equipment_slot_count : int = 6

func _init() -> void:
	connect_slots()
	pass

func inventorySlots() -> Array[SlotData] :
	return slots.slice(0, -equipment_slot_count)

func equipmentSlots() -> Array[SlotData]:
	return slots.slice(-equipment_slot_count,slots.size())

func add_item(item : ItemData, count : int = 1) -> bool:
	if item is AbilityItemData:
		ability_acquired.emit(item)
		return true
	for s in slots:
		if s :
			if s.item_data == item :
				s.quantity += count
				return true

	for i in inventorySlots().size():
		if slots[i] == null:
			var new = SlotData.new()
			new.item_data = item
			new.quantity = count
			slots[i] = new
			new.changed.connect(slotChanged)
			return true
	
	print("INVENTORY FULL U FOOL !")
	
	return false


func connect_slots() -> void:
	for s in slots:
		if s:
			s.changed.connect(slotChanged)

func slotChanged() -> void:
	for s in slots:
		if s:
			if s.quantity < 1:
				s.changed.disconnect(slotChanged)
				var index = slots.find(s)
				slots[index] = null
				emit_changed()
	pass

func getSaveData() -> Array:
	var item_save : Array = []
	for i in slots.size():
		item_save.append(itemToSave(slots[i]))
	return item_save

func itemToSave( slot : SlotData) -> Dictionary:
	var result = { item = "", quantity = 0}
	if slot != null:
		result.quantity = slot.quantity
		if slot.item_data != null:
			result.item = slot.item_data.resource_path
	
	return result

func parseSaveData( saveData : Array) -> void:
	var arraySize = slots.size()
	slots.clear()
	slots.resize(arraySize)
	for i in saveData.size():
		slots[i] = itemFromSave(saveData[i])
	connect_slots()
	pass
	

func itemFromSave( saveObject : Dictionary ) -> SlotData:
	if saveObject.item == "":
		return null
	var newSlot : SlotData = SlotData.new()
	newSlot.item_data = load(saveObject.item )
	newSlot.quantity = int(saveObject.quantity)
	return newSlot

func useItem(item : ItemData, count : int = 1 ) -> bool:
	for s in slots:
		if s:
			if s.item_data == item and s.quantity >= count:
				s.quantity -= count
				return true
	return false

func swapItemByIndex(_i1 : int, _i2 : int) -> void:
	var temp : SlotData = slots[_i1]
	slots[_i1] = slots[_i2]
	slots[_i2] = temp
	pass

func equipItem(slot : SlotData ) -> void:
	if slot == null or not slot.item_data is EquipableItemData:
		return
	var  item : EquipableItemData = slot.item_data
	var slot_index : int = slots.find(slot)
	var equipment_index : int = slots.size() - equipment_slot_count
	
	match item.type:
		EquipableItemData.Type.ARMOR:
			equipment_index += 0
			pass
		EquipableItemData.Type.AMULET:
			equipment_index += 1
			pass
		EquipableItemData.Type.WEAPON:
			equipment_index += 2
			pass
		EquipableItemData.Type.RING:
			equipment_index += 3
			pass
		EquipableItemData.Type.SHIELD:
			equipment_index += 4
			pass
		EquipableItemData.Type.TOOL:
			equipment_index += 5
			pass
	var unequiped_slot : SlotData = slots[equipment_index]
	
	slots[slot_index ] = unequiped_slot
	slots[equipment_index] = slot
	
	equipment_changed.emit()
	PauseMenu.focusedItemChanged(unequiped_slot)
	pass

func getAttackBonus() -> int:
	return getEquipmentBonus(EquipableItemModifier.Type.ATTACK)

func getAttackBonusDiff(item : EquipableItemData) -> int:
	@warning_ignore("unused_variable")
	var diff = 0
	
	var before : int = getAttackBonus()
	var after : int =  getEquipmentBonus(EquipableItemModifier.Type.ATTACK, item)
	
	return after - before

func getDefenseBonusDiff(item : EquipableItemData) -> int:
	@warning_ignore("unused_variable")
	var diff = 0
	
	var before : int = getDefendBonus()
	var after : int =  getEquipmentBonus(EquipableItemModifier.Type.DEFENSE, item)
	
	return after - before

func getDefendBonus() -> int:
	return getEquipmentBonus(EquipableItemModifier.Type.DEFENSE)

func getEquipmentBonus( bonus_type : EquipableItemModifier.Type, compare : EquipableItemData = null) -> int:
	var bonus : int = 0
	
	for s in equipmentSlots():
		if s == null :
			continue
		var e : EquipableItemData = s.item_data
		if compare :
			if e.type == compare.type:
				e = compare
		for m in e.modifiers:
			if m.type == bonus_type:
				bonus += m.value
	
	return bonus

func getItemHeldCount(_item : ItemData) -> int:
	for slot in slots:
		if slot:
			if slot.item_data:
				if slot.item_data == _item:
					return slot.quantity
	return 0
