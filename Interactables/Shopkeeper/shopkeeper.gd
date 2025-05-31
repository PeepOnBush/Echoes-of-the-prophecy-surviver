class_name ShopKeeper extends Node2D

@export var shop_inventory : Array[ItemData]

@onready var dialog_branch_yes: DialogBranch = $Npc/DialogInteraction/DialogChoice/DialogBranch


func _ready() -> void:
	dialog_branch_yes.selected.connect(showShopMenu)
	pass

func showShopMenu() -> void:
	print("show shop")
	ShopMenu.showMenu(shop_inventory)
	pass
