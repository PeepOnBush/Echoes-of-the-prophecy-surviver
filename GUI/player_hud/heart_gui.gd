class_name HeartGui extends Control


@onready var sprite = $Sprite2D

var value : int = 2 :
	set(_value ):
		value = _value
		updateSprite()


func updateSprite() -> void:
	sprite.frame = value
