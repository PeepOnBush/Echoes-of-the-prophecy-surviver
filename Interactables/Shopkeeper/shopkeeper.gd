class_name ShopKeeper extends Node2D

@export_category("Item for sale")
@export var shop_inventory : Array[ItemData]


func _ready() -> void:
	pass

func open_shop_ui() -> void:
	print("Opening Shop...")
	# We assume ShopMenu is an Autoload or accessible via Global
	# Or access it via PlayerHud if that's where you put it
	# Based on previous chats, let's use the static function you had:
	ShopMenu.showMenu(shop_inventory)
