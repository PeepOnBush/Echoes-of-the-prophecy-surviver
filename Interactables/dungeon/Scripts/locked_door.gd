class_name LockedDoor extends Node2D

var isOpen : bool = false

@export var key_item : ItemData #What kind of item can open this
@export var lockedAudio : AudioStream 
@export var openAudio : AudioStream


@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var isOpenData : PersistentDataHandler = $PersistentDataHandler
@onready var interact_area : Area2D = $InteractArea2D

func _ready() -> void:
	interact_area.area_entered.connect( onAreaEnter)
	interact_area.area_exited.connect( onAreaExit)
	isOpenData.dataLoaded.connect( setState)
	setState()
	pass

func onAreaEnter(_a : Area2D) -> void:
	PlayerManager.interact_pressed.connect(openDoor)
	pass

func onAreaExit( _a : Area2D) -> void:
	PlayerManager.interact_pressed.disconnect(openDoor)
	pass

func openDoor() -> void:
	if key_item == null:
		return
	var door_unlocked = PlayerManager.INVENTORY_DATA.useItem(key_item)
	if door_unlocked:
		animation_player.play("open_door")
		animation_player.play()
		audio.stream = openAudio
		isOpenData.setValue()
	else:
		audio.stream = lockedAudio
	audio.play()
	pass

func setState() -> void:
	isOpen = isOpenData.value
	if isOpen:
		animation_player.play("opened")
	else:
		animation_player.play("closed")
	pass


func closeDoor() -> void:
	animation_player.play("close_door")


	
