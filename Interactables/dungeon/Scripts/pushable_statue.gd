class_name PushableStatue extends RigidBody2D

@export var pushSpeed : float = 30.0
@export var persistent : bool = false
@export var persistent_location : Vector2 = Vector2.ZERO
@export var target_location_size : Vector2 = Vector2( 4 , 4 )

var pushDirection : Vector2 = Vector2.ZERO : set = setPush
var on_target : bool = false
@onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var persistent_data_handler : PersistentDataHandler = $OnTarget


func _ready() -> void:
	if persistent_data_handler.value == true:
		position = persistent_location
	pass


func _physics_process( _delta : float) -> void:
	linear_velocity = pushDirection * pushSpeed
	if persistent:
		# if the x coordinate is on target/close enough
		var x_is_on : bool = abs( position.x - persistent_location.x ) < 15 + target_location_size.x
		var y_is_on : bool = abs(position.y - persistent_location.y) < 6 + target_location_size.y
		if x_is_on and y_is_on and on_target == false:
			on_target = true
			persistent_data_handler.setValue()
		elif ( x_is_on == false and y_is_on == false ) and on_target == true:
			on_target = false
			persistent_data_handler.removeValue()
	pass

func setPush( value : Vector2 ) -> void:
	pushDirection = value
	if pushDirection == Vector2.ZERO:
		audio.stop()
	else:
		audio.play()
	pass
