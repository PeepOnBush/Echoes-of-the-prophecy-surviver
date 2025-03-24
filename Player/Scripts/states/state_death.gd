class_name StateDeath extends State

@export var exhaust_audio : AudioStream
@onready var audio: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func init() -> void:
	pass

## What happen when the player enter this state ?
func Enter() -> void:
	player.animationPlayer.play("death")
	audio.stream = exhaust_audio
	audio.play()
	#trigger game over ui
	AudioManager.playMusic(null)
	
	pass
## What happen when the player exit this state ?
func Exit() -> void:
	
	pass 
## What happen when the _process update in this state ?
func Process(_delta : float) -> State:
	player.velocity = Vector2.ZERO
	return null
	
func Physics(_delta : float) -> State:
	return null

func HandleInput( _event : InputEvent ) -> State:
	return null
