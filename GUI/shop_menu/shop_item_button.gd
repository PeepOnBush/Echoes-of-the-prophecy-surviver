class_name ShopItemButton extends Button

var item : ItemData 

func setupItem(_item : ItemData) -> void:
	item = _item
	$Label.text = item.name
	$Currency.text = str(item.cost)
	$TextureRect.texture = item.texture
	pass
