extends Node

const SETTINGS_PATH = "user://settings.cfg"

# Define the input actions you want to save so we don't save UI/Editor inputs
var saveable_actions = ["attack", "dash", "interact", "ability", "pause", "ui_accept"]

var config = ConfigFile.new()

func _ready():
	load_settings()

func save_settings():
	# 1. SAVE AUDIO (Assuming setup from Pause Menu)
	config.set_value("Audio", "master", AudioServer.get_bus_volume_db(0))
	config.set_value("Audio", "music", AudioServer.get_bus_volume_db(1))
	config.set_value("Audio", "sfx", AudioServer.get_bus_volume_db(2))
	
	# 2. SAVE VIDEO
	config.set_value("Video", "fullscreen", DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	config.set_value("Video", "vsync", DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED)
	
	# 3. SAVE KEYS (The Magic Part)
	# We iterate through our list of actions
	for action in saveable_actions:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			# We save the FIRST event (Keyboard/Mouse) for that action
			# var_to_str converts the InputObject into a text string Godot can read later
			config.set_value("Inputs", action, var_to_str(events[0]))
	
	# Write to disk
	config.save(SETTINGS_PATH)

func load_settings():
	var err = config.load(SETTINGS_PATH)
	if err != OK:
		return # No file found (First run), skip loading
	
	# 1. LOAD AUDIO
	AudioServer.set_bus_volume_db(0, config.get_value("Audio", "master", 0.0))
	AudioServer.set_bus_volume_db(1, config.get_value("Audio", "music", 0.0))
	AudioServer.set_bus_volume_db(2, config.get_value("Audio", "sfx", 0.0))
	
	# 2. LOAD VIDEO
	var fullscreen = config.get_value("Video", "fullscreen", false)
	var vsync = config.get_value("Video", "vsync", true)
	
	if fullscreen: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	if vsync: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	# 3. LOAD KEYS
	for action in saveable_actions:
		# Check if this specific action was saved
		if config.has_section_key("Inputs", action):
			var event_str = config.get_value("Inputs", action)
			# Convert string back to InputEvent Object
			var event = str_to_var(event_str)
			
			if event:
				# Clear defaults and set new key
				InputMap.action_erase_events(action)
				InputMap.action_add_event(action, event)
