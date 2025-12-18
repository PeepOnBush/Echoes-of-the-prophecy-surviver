extends Node2D

@onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_campfire : AudioStream = preload("res://Props/Campfire/campfire-crackling-fireplace-sound-119594.wav") 
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fire_animation: AnimatedSprite2D = $FireAnimation

func _ready() -> void:
	fire_animation.play("burning")
	animation_player.play("smoking")
	playAudio(audio_campfire)
	pass

func playAudio(_stream : AudioStream) -> void:
	audio.stream = _stream
	audio.play()
