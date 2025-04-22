class_name  InventoryData extends Resource

@export var slots : Array[ SlotData ]


func _init() -> void:
	connect_slots()
	pass

func add_item(item : ItemData, count : int = 1) -> bool:
	for s in slots:
		if s :
			if s.item_data == item :
				s.quantity += count
				return true

	for i in slots.size():
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
