@tool
@icon("res://GUI/dialog_system/Icons/result_bubble.svg") # You can reuse an icon or make a new one
class_name DialogResult extends DialogItem

# Emitted when the dialog system reaches this node.
# Connect this in the editor to do simple things like "Queue Free" or "AnimationPlayer.play"
signal triggered

# Useful if you want a pause after the action (like a sound effect playing)
@export var delay_after_action : float = 0.0

func _ready() -> void:
	# Hide sprite/visuals in game if you have any attached for editor visualization
	if Engine.is_editor_hint():
		return
	pass
# This is called by the DialogSystem
func execute() -> void:
	# 1. Trigger the logic
	_on_execute()
	triggered.emit()
	
	# 2. Wait if needed
	if delay_after_action > 0:
		await get_tree().create_timer(delay_after_action).timeout
	
	# 3. Tell the system we are done
	# Assuming DialogSystem is your Autoload name
	# If not, we might need to pass the reference or use a signal
	pass

# VIRTUAL FUNCTION: Override this in specific scripts for complex logic
func _on_execute() -> void:
	pass
