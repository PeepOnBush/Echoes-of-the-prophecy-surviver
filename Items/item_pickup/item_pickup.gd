@tool
class_name ItemPickup extends CharacterBody2D

signal pickedUp

@export var item_data : ItemData : set = setItemData 
@export var item_count : int = 1 : set = setItemCount

@onready var area_2d : Area2D = $Area2D
@onready var audio_stream_player_2d : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite_2d : Sprite2D = $Sprite2D
@onready var count_label: Label = %CountLabel

func _ready() -> void:
	updateTexture()
	updateCountLabel()
	if Engine.is_editor_hint():
		return
	area_2d.body_entered.connect( _onBodyEnter )

func _physics_process(delta : float) -> void:
	var collisionInfo = move_and_collide( velocity * delta)
	if collisionInfo:
		velocity = velocity.bounce(collisionInfo.get_normal()) 
	velocity -= velocity * delta * 4


func setItemData(value : ItemData ) -> void:
	updateTexture()
	item_data = value
	pass

func setItemCount(value : int ) -> void:
	item_count = value
	updateCountLabel()
	pass

func _onBodyEnter(b) -> void:
	if b is Player:
		if item_data:
			if item_data.name == "Bomb":
				PlayerManager.player.bomb_count += item_count
				itemPickedUp()
			elif item_data.name == "Arrow":
				PlayerManager.player.arrow_count += item_count
				itemPickedUp()
			elif PlayerManager.INVENTORY_DATA.add_item(item_data,item_count) == true:
				itemPickedUp()
	pass

func itemPickedUp() -> void:
	area_2d.body_entered.disconnect(_onBodyEnter)
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

func updateCountLabel() -> void:
	if item_data and count_label:
		count_label.text = ""
		if item_count > 1 :
			count_label.text = str(item_count)
	pass
