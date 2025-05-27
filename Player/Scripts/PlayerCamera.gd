class_name PlayerCamera extends Camera2D



@export_range(0 ,1 ,0.5 , "or_greater") var shake_power = 0.5 # overal strength of shake
@export var shake_max_offset : float = 5.0 #Maximum shake in pixels
@export var shake_decay : float = 1.0 # how quick the shake stop

var shake_trauma : float = 0.0
# Called when the node enters the scene tree for the first time.
func _ready():
	LevelManager.TileMapsBoundChanged.connect(UpdateLimit)
	UpdateLimit(LevelManager.Current_TileMaps_Bounds)
	PlayerManager.camera_shook.connect(addCameraShake)
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if shake_trauma > 0:
		shake_trauma = max(shake_trauma - shake_decay * delta,0)
		shake()
		pass
	pass

func shake() -> void:
	var ammount : float = pow(shake_trauma * shake_power,2)
	offset = Vector2(randf_range(-1 , 1 ), randf_range( -1 , 1)) * shake_max_offset * ammount
	
	pass

func addCameraShake(val : float) -> void:
	shake_trauma = val
	pass

func UpdateLimit(bounds : Array[Vector2]) -> void :
	if bounds == []:
		return
	limit_left = int(bounds[0].x)
	limit_top = int(bounds[0].y)
	limit_right = int(bounds[1].x)
	limit_bottom = int(bounds[1].y)
	pass
