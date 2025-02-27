class_name SlotData extends Resource

@export var item_data : ItemData
@export var quantity : int = 0 : set = setQuantity

func setQuantity( value : int) -> void:
	quantity = value
	if quantity < 1:
		emit_changed()
