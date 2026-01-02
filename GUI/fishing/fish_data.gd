class_name FishData extends Resource

enum Rarity { COMMON, UNCOMMON, RARE, MYTHICAL, LEGENDARY }

@export var name : String = "Salmon"
@export var icon : Texture2D
@export var rarity : Rarity = Rarity.COMMON

# The "Weight" of the fish. 
# 1.0 = Standard. 2.0 = Very Heavy (Hard to pull up, falls fast).
@export_range(0.5, 3.0) var weight_difficulty : float = 1.0
