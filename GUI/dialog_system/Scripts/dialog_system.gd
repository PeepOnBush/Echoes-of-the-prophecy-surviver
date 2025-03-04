@tool
@icon("res://GUI/dialog_system/Icons/star_bubble.svg") 
class_name DialogSystemNode extends CanvasLayer

var isActive : bool = false
@onready var dialog_ui: Control = $DialogUi


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		if get_viewport() is Window:
			get_parent().remove_child(self)
			return
		return
	hideDialog()
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		if isActive == false:
			showDialog()
		else:
			hideDialog()
	pass

func showDialog() -> void:
	isActive = true
	dialog_ui.visible = true
	dialog_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	print("Node Changed")
	get_tree().paused = true
	pass

func hideDialog() -> void:
	isActive = false
	dialog_ui.visible = false
	dialog_ui.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false
	pass
