extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_campfire : AudioStream = preload("res://Props/Campfire/campfire-crackling-fireplace-sound-119594.wav") 

func _ready() -> void:
	animated_sprite_2d.play("burning")
	playAudio(audio_campfire)
	pass

func playAudio(_stream : AudioStream) -> void:
	audio.stream = _stream
	audio.play()
