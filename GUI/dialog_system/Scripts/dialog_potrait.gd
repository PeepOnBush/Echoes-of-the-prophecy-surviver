@tool
class_name DialogPotrait extends Sprite2D


var blink : bool = false : set = setBlink
var open_mouth : bool = false : set = setOpenMouth
var mouth_open_frames : int = 0
var audio_pitch_base : float = 1.0

@onready var audio_stream_player: AudioStreamPlayer = $"../AudioStreamPlayer"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	DialogSystem.letter_added.connect(checkMouthOpen)
	blinker()
	pass # Replace with function body.

func checkMouthOpen( l : String) -> void:
	if 'aeiouy1234567890'.contains(l):
		open_mouth = true
		mouth_open_frames += 3
		audio_stream_player.pitch_scale = randf_range(audio_pitch_base - 0.04 ,audio_pitch_base + 0.04 )
		audio_stream_player.play()
	elif '.,!?'.contains(l):
		audio_stream_player.pitch_scale = audio_pitch_base - 0.1
		audio_stream_player.play()
		mouth_open_frames = 0
	
	if mouth_open_frames > 0:
		mouth_open_frames -= 1
	
	if mouth_open_frames == 0:
		if open_mouth == true:
			open_mouth = false
			audio_stream_player.pitch_scale = randf_range(audio_pitch_base - 0.08 ,audio_pitch_base + 0.02 )
			audio_stream_player.play()
	pass

func updatePotrait() -> void:
	if open_mouth == true:
		frame = 2
	else : 
		frame = 0
	
	if blink == true:
		frame += 1

func setBlink(_value : bool) -> void:
	if blink != _value:
		blink = _value
		updatePotrait()
	pass

func blinker() -> void:
	if blink == false:
		await get_tree().create_timer(randf_range(0.1,3)).timeout
	else:
		await get_tree().create_timer(0.15).timeout
	blink = not blink
	blinker()

func setOpenMouth(_value : bool) -> void:
	if open_mouth != _value:
		open_mouth = _value
		updatePotrait()
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
