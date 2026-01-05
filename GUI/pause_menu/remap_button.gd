class_name RemapButton extends HBoxContainer

@export var action : String = "attack" # The exact name from Project Settings -> Input Map

@onready var action_label: Label = $ActionName
@onready var key_button: Button = $KeyButton

func _ready() -> void:
	# 1. Set the Label to look nice (Capitalize "attack" -> "Attack")
	action_label.text = action.capitalize()
	
	# 2. Find the current key assigned to this action and show it
	update_key_text()
	
	# 3. Connect signal
	key_button.toggled.connect(_on_button_toggled)

func update_key_text() -> void:
	# Get the list of inputs for this action (Array)
	var events = InputMap.action_get_events(action)
	
	if events.size() > 0:
		# We grab the first event (usually Keyboard or Mouse)
		# .as_text() converts the internal ID to "Space", "W", "Left Mouse Button"
		key_button.text = events[0].as_text().trim_suffix(" (Physical)")
	else:
		key_button.text = "None"

func _on_button_toggled(is_pressed: bool) -> void:
	if is_pressed:
		# VISUAL FEEDBACK: Let the player know we are waiting
		key_button.text = "Press Any Key..."
		release_focus() # Stop keyboard from triggering UI navigation while listening
	else:
		# If we cancelled or finished, update the text back
		update_key_text()

func _input(event: InputEvent) -> void:
	# Only listen if the button is currently PRESSED (Waiting state)
	if key_button.button_pressed:
		
		# We only care about Keys or Mouse Buttons (ignore Mouse Motion)
		if event is InputEventKey or event is InputEventMouseButton:
			
			# 1. Don't let the key press do anything else in the game
			get_viewport().set_input_as_handled()
			
			# 2. Modify the Engine's InputMap
			remap_action_to(event)
			
			# 3. Turn off the "Waiting" state
			key_button.button_pressed = false

func remap_action_to(event : InputEvent) -> void:
	# Clear old keys
	InputMap.action_erase_events(action)
	
	# Add new key
	InputMap.action_add_event(action, event)
	
	# Update the Button Text immediately
	update_key_text()
	
	# Optional: Play a "Confirm" sound here
	# GlobalAudioManager.play_sfx(...)
