extends Button

@export_multiline var description : String = ""



func _ready() -> void: 
	focus_entered.connect(onFocusEntered)
	pass

func onFocusEntered() -> void:
	PauseMenu.updateItemDescription(description)
	pass
