extends CanvasLayer

const RECIPE_BUTTON_PATH = "res://GUI/cooking/shop_recipe_button.tscn"
@onready var grid_container: VBoxContainer = %ShopItemsContainer # Reuse the container
@onready var close_btn: Button = %CloseButton

var current_npc_recipes : Array[RecipeData]

func _ready() -> void:
	visible = false
	close_btn.pressed.connect(close_menu)

func open_menu(recipes : Array[RecipeData]) -> void:
	get_tree().paused = true
	visible = true
	current_npc_recipes = recipes
	
	populate_list()

func populate_list() -> void:
	# Clear old list
	for c in grid_container.get_children():
		c.queue_free()
		
	# Spawn Buttons
	for r in current_npc_recipes:
		var btn_scene = load(RECIPE_BUTTON_PATH)
		var btn = btn_scene.instantiate()
		grid_container.add_child(btn)
		btn.setup(r)
		
		# CONNECT CLICK
		# If button is enabled (has ingredients), connecting the click triggers logic
		if btn.has_ingredients:
			btn.pressed.connect(on_recipe_selected.bind(r))

func on_recipe_selected(recipe : RecipeData) -> void:
	# 1. Remove Ingredients
	for i in recipe.ingredients:
		PlayerManager.INVENTORY_DATA.useItem(i, 1)
	
	# 2. Close this Menu
	close_menu()
	
	# 3. WIRE UP TO MINIGAME (This calls PlayerHud)
	# IMPORTANT: We need a slight delay so the pause state handles correctly
	await get_tree().process_frame
	PlayerHud.start_cooking(recipe)

func close_menu() -> void:
	visible = false
	get_tree().paused = false # Unpause (Minigame will re-pause it immediately)
