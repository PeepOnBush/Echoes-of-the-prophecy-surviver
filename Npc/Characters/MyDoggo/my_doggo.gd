class_name my_doggo extends Node2D

@onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var dog_panting : AudioStream = preload("res://Npc/Characters/MyDoggo/dog_pant.mp3") 

func _ready() -> void:
	playAudio(dog_panting)
	pass
func playAudio(_stream : AudioStream) -> void:
	audio.stream = _stream
	audio.play()
