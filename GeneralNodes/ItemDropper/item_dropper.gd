@tool
class_name ItemDropper extends Node2D

const PICKUP = preload("res://Items/item_pickup/ItemPickup.tscn")

@export var item_data : ItemData : set = setItemData

var hasDropped : bool = false

@onready var sprite : Sprite2D = $Sprite2D
@onready var has_dropped_data : PersistentDataHandler = $PersistentDataHandler
@onready var audio : AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	if Engine.is_editor_hint() == true:
		updateTexture()
		return
		
	sprite.visible = false
	has_dropped_data.dataLoaded.connect( onDataLoaded)
	onDataLoaded()

func dropItem() -> void:
	if hasDropped == true:
		return
	hasDropped = true
	
	
	var drop = PICKUP.instantiate() as ItemPickup
	drop.item_data= item_data
	add_child( drop)
	drop.pickedUp.connect(onDropPickUp)
	audio.play()

func onDropPickUp() -> void:
	has_dropped_data.setValue()


func onDataLoaded() -> void:
	hasDropped = has_dropped_data.value
	pass


func setItemData( value : ItemData) -> void:
	item_data = value 
	updateTexture()
	pass

func updateTexture() -> void:
	if Engine.is_editor_hint() == true:
		if item_data and sprite:
			sprite.texture = item_data.texture
	pass


func _on_enemy_counter_level_cleared():
	pass # Replace with function body.
