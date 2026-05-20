@tool
class_name treasure_chest extends Node2D

var isOpen : bool = false

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var interactArea : Area2D = $Area2D

func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	# Ensure it always starts closed when loading into the level
	animation_player.play("closed")
		
	interactArea.area_entered.connect(onAreaEnter)
	interactArea.area_exited.connect(onAreaExit)

func playerInteract() -> void:
	# Prevent double-clicking while it's already open
	if isOpen == true:
		return
		
	isOpen = true
	animation_player.play("open_chest")
	
	# Connect to the UI's close signal so we know when to shut the lid.
	# CONNECT_ONE_SHOT ensures it only listens for this specific opening event.
	ChestMenu.menu_closed.connect(_on_menu_closed, CONNECT_ONE_SHOT)
	
	# Open the UI using the RESIDENT EVIL GLOBAL CHEST!
	ChestMenu.open_chest(PlayerManager.GLOBAL_CHEST_DATA)

func _on_menu_closed() -> void:
	isOpen = false
	animation_player.play("close_chest")
	# Optional: Play a nice heavy wooden "thud" sound effect here!

func onAreaEnter(_a : Area2D) -> void:
	PlayerManager.interact_pressed.connect(playerInteract)

func onAreaExit( _a : Area2D) -> void:
	PlayerManager.interact_pressed.disconnect(playerInteract)
