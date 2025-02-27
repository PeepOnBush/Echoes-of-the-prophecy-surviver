class_name PlayerCamera extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	LevelManager.TileMapsBoundChanged.connect(UpdateLimit)
	UpdateLimit(LevelManager.Current_TileMaps_Bounds)
	pass # Replace with function body.


func UpdateLimit(bounds : Array[Vector2]) -> void :
	if bounds == []:
		return
	limit_left = int(bounds[0].x)
	limit_top = int(bounds[0].y)
	limit_right = int(bounds[1].x)
	limit_bottom = int(bounds[1].y)
	pass
