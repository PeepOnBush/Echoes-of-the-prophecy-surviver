@tool
@icon("res://GUI/dialog_system/Icons/chat_bubbles.svg")
class_name DialogInteraction extends Area2D

signal player_interacted
signal finished

@export var enabled : bool = true

var dialog_items : Array[DialogItem]

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	area_entered.connect( onAreaEnter )
	area_exited.connect( onAreaExit )
	for c in get_children():
		if c is DialogItem:
			dialog_items.append(c)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _get_configuration_warnings() -> PackedStringArray:
	if checkForDialogItems() == false:
		return ["Requires atleast 1 DialogItem node."]
	else:
		return []
	#check for dialog

func checkForDialogItems() -> bool:
	for c in get_children():
		if c is DialogItem:
			return true
	return false

func playerInteract() -> void:
	player_interacted.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	DialogSystem.showDialog(dialog_items)
	DialogSystem.finished.connect( _on_dialog_finished )
	pass

func onAreaEnter(_a : Area2D) -> void:
	if enabled == false || dialog_items.size() == 0:
		return
	animation_player.play("show")
	PlayerManager.interact_pressed.connect(playerInteract)
	pass

func onAreaExit(_a : Area2D) -> void:
	animation_player.play("hide")
	PlayerManager.interact_pressed.disconnect(playerInteract)
	pass

func  _on_dialog_finished () -> void:
	print("nothing to check")
	DialogSystem.finished.disconnect(_on_dialog_finished)
	finished.emit()
