class_name RecipeData extends Resource

@export var recipe_name : String
@export var result_item : ItemData       # The Stew/Soup you get
@export var ingredients : Array[ItemData] # List of items needed (e.g. 1 Fish, 1 Slime)
# If you want 5 fish, add the Fish item 5 times to this array for simplicity for now.
@export var difficulty : float = 1.0      # 1.0 = Normal speed minigame
