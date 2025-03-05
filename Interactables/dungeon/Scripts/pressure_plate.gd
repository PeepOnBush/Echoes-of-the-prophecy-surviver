class_name pressure_player extends Node2D

signal pressed
signal unpressed

var bodies : int = 0 
var isPress : bool = false
var offRect : Rect2


@onready var area_2d : Area2D = $Area2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_activate : AudioStream = preload("res://Interactables/dungeon/lever-01.wav") 
@onready var audio_deactivate : AudioStream = preload("res://Interactables/dungeon/lever-02.wav")
@onready var sprite : Sprite2D = $Sprite2D


func _ready() -> void:
	area_2d.body_entered.connect( onBodyEntered)
	area_2d.body_exited.connect(onBodyExited)
	offRect = sprite.region_rect
	pass

func onBodyEntered( _b : Node2D) -> void:
	bodies += 1 
	checkIsActivated()
	pass

func onBodyExited( _b : Node2D) -> void:
	bodies -= 1
	checkIsActivated()
	pass

func checkIsActivated() -> void:
	if bodies > 0 and isPress == false:
		isPress = true
		sprite.region_rect.position.x = offRect.position.x - 32
		playAudio(audio_activate)
		pressed.emit()
	elif bodies <= 0 and isPress == true:
		isPress = false
		sprite.region_rect.position.x = offRect.position.x 
		playAudio(audio_deactivate)
		unpressed.emit()

func playAudio(_stream : AudioStream) -> void:
	audio.stream = _stream
	audio.play()
