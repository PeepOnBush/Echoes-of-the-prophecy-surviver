@tool
class_name ItemPickup extends CharacterBody2D

signal pickedUp

@export var item_data : ItemData : set = setItemData 

@onready var area_2d : Area2D = $Area2D
@onready var audio_stream_player_2d : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite_2d : Sprite2D = $Sprite2D

func _ready() -> void:
	updateTexture()
	if Engine.is_editor_hint():
		return
	area_2d.body_entered.connect( onBodyEnter )

func _physics_process(delta : float) -> void:
	var collisionInfo = move_and_collide( velocity * delta)
	if collisionInfo:
		velocity = velocity.bounce(collisionInfo.get_normal()) 
	velocity -= velocity * delta * 4


func setItemData(value : ItemData ) -> void:
	updateTexture()
	item_data = value
	pass

func onBodyEnter(b) -> void:
	if b is Player:
		if item_data:
			if PlayerManager.INVENTORY_DATA.add_item(item_data) == true:
				itemPickedUp()
	pass

func itemPickedUp() -> void:
	area_2d.body_entered.disconnect( onBodyEnter)
	audio_stream_player_2d.play()
	visible = false
	pickedUp.emit()
	await audio_stream_player_2d.finished
	queue_free()
	pass

func updateTexture() -> void:
	if item_data and sprite_2d:
		sprite_2d.texture = item_data.texture
	pass
