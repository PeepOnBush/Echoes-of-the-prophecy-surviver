@tool
class_name treasure_chest extends Node2D

@export var item_data : ItemData : set = setItemData
@export var quantity : int = 1 : set = setQuantity

var isOpen : bool = false


@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $ItemSprite
@onready var label : Label = $ItemSprite/Label
@onready var interactArea : Area2D = $Area2D
@onready var persistent_data_is_open : PersistentDataHandler = $PersistentDataIsOpen


func _ready() -> void:
	updateLabel()
	updateTexture()
	if Engine.is_editor_hint():
		return
	interactArea.area_entered.connect(onAreaEnter)
	interactArea.area_exited.connect(onAreaExit)
	persistent_data_is_open.dataLoaded.connect(setChestState)
	setChestState()
	pass

func setChestState() -> void:
	isOpen = persistent_data_is_open.value
	if isOpen:
		animation_player.play("opened")
	else:
		animation_player.play("closed")
func playerInteract() -> void:
	if isOpen == true:
		return
	isOpen = true
	persistent_data_is_open.setValue()
	animation_player.play("open_chest")
	if item_data and quantity > 0:
		PlayerManager.INVENTORY_DATA.add_item(item_data, quantity)
	else:
		printerr("No items in chest !!")
		push_error("No items in chest! chest name", name)
	pass

func onAreaEnter(_a : Area2D) -> void:
	PlayerManager.interact_pressed.connect(playerInteract)
	pass

func onAreaExit( _a : Area2D) -> void:
	PlayerManager.interact_pressed.disconnect(playerInteract)
	pass

func setItemData( value : ItemData) -> void:
	item_data = value
	updateTexture()
	pass

func setQuantity( value : int ) -> void:
	quantity = value
	updateLabel()
	pass

func updateTexture() -> void:
	if item_data and sprite : 
		sprite.texture = item_data.texture
	pass

func updateLabel() -> void:
	if label:
		if quantity <= 1 :
			label.text = ""
		else:
			label.text = "x" + str(quantity)
