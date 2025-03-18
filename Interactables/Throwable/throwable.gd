class_name Throwable extends Area2D

@export var gravity_string : float = 980.0
@export var throw_speed : float = 400.0
@export var throw_height_strength : float = 100
@export var throw_starting_height : float = 49

var picked_up : bool = false
var throwable : Node2D

@onready var hurt_box : HurtBox = $HurtBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(onAreaEnter)
	area_exited.connect(onAreaExit)
	throwable = get_parent()
	setupHurtBox()
	pass # Replace with function body.

func playerInteract() -> void:
	# pick 1 object only
	if picked_up == false:
		#pick up throwable object
		print("picked up pot")
		pass
	pass

func onAreaEnter(_a : Area2D) -> void:
	PlayerManager.interact_pressed.connect(playerInteract)
	pass

func onAreaExit(_a : Area2D) -> void:
	PlayerManager.interact_pressed.disconnect(playerInteract)
	pass

func setupHurtBox() -> void:
	hurt_box.monitoring = false 
	for c in get_children():
		if c is CollisionShape2D:
			var _col : CollisionShape2D = c.duplicate()
			hurt_box.add_child(_col)
			_col.debug_color = Color(1,0,0,0.5)
