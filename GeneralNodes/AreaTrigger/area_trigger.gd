class_name AreaTrigger extends Area2D

signal player_entered

var dialog : DialogInteraction
var triggered : bool = false

func _ready() -> void:
	body_entered.connect(onBodyEntered)
	for c in get_children():
		if c is DialogInteraction:
			dialog = c
			break
	pass

func onBodyEntered(_body : Node2D) -> void:
	if triggered:
		return
	player_entered.emit()
	if dialog:
		triggered = true
		dialog.playerInteract()
	pass
