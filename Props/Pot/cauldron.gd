class_name Cauldron extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_cauldron : AudioStream = preload("res://Props/Pot/boiling_water_final.mp3") 


func _ready() -> void:
	animation_player.play("smoking")
	playAudio(audio_cauldron)
	pass

func playAudio(_stream : AudioStream) -> void:
	audio.stream = _stream
	audio.play()
