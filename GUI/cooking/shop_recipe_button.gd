class_name RecipeButton extends Button

var recipe : RecipeData
var has_ingredients : bool = false

@onready var icon_rect: TextureRect = $TextureRect # Adjust path
@onready var label: Label = $Label
@onready var ingredients_container: HBoxContainer = $IngredientsContainer

func setup(_recipe : RecipeData) -> void:
	recipe = _recipe
	label.text = _recipe.recipe_name
	icon_rect.texture = _recipe.result_item.texture
	
	check_ingredients_logic()

func check_ingredients_logic() -> void:
	# 1. Clear old icons
	for c in ingredients_container.get_children(): c.queue_free()
	
	has_ingredients = true
	
	# 2. Check each ingredient
	for ingredient in recipe.ingredients:
		# Create a visual icon for the ingredient
		var ingredient_icon = TextureRect.new()
		ingredient_icon.texture = ingredient.texture
		ingredient_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ingredient_icon.custom_minimum_size = Vector2(24, 24)
		ingredients_container.add_child(ingredient_icon)
		
		# LOGIC CHECK
		if PlayerManager.INVENTORY_DATA.getItemHeldCount(ingredient) < 1:
			has_ingredients = false
			ingredient_icon.modulate = Color(1, 0, 0, 0.5) # Turn icon Red/Transparent if missing
	
	# 3. Disable button if missing items
	disabled = not has_ingredients
	
	if disabled:
		label.text += " (Missing Items)"
		modulate = Color(0.6, 0.6, 0.6) # Dim the whole button
