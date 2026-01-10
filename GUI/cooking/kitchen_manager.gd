class_name KitchenShopKeeper extends ShopKeeper

@export_category("Cooking")
@export var my_recipes : Array[RecipeData]

func open_kitchen_ui() -> void:
	print("Opening Kitchen...")
	
	#Call the Global Autoload directly
	RecipeMenu.open_menu(my_recipes)
