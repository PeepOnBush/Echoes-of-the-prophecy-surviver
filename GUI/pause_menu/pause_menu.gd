extends CanvasLayer

signal shown
signal hidden
signal preview_stats_change( item : ItemData )

@onready var audio_stream_player : AudioStreamPlayer = $Control/AudioStreamPlayer
@onready var tab_container: TabContainer = $Control/TabContainer
@export var button_select_audio : AudioStream = preload("res://GUI/pause_menu/button_pressing.mp3")
@export var button_focus_audio : AudioStream = preload("res://GUI/pause_menu/button_pressing.mp3")
@onready var btn_save : Button =  $Control/TabContainer/System/VBoxContainer/btn_save
@onready var btn_load : Button = $Control/TabContainer/System/VBoxContainer/btn_load
@onready var btn_quit: Button = $Control/TabContainer/System/VBoxContainer/btn_quit
@onready var btn_menu: Button = $Control/TabContainer/System/VBoxContainer/btn_menu
@onready var item_description_panel : ItemDescriptionPanel = $Control/TabContainer/Inventory/ItemDescriptionPanel
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SfxSlider
@onready var window_mode_btn: OptionButton = %WindowModeBtn
@onready var vsync_btn: CheckBox = %VsyncBtn


var is_paused : bool = false
var is_setting_up_ui : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hidePauseMenu()
	btn_save.focus_entered.connect(playAudio.bind(button_focus_audio))
	btn_load.focus_entered.connect(playAudio.bind(button_focus_audio))
	btn_menu.focus_entered.connect(playAudio.bind(button_focus_audio))
	btn_quit.focus_entered.connect(playAudio.bind(button_focus_audio))

	btn_save.pressed.connect(onSavePressed)
	btn_load.pressed.connect(onLoadPressed)
	btn_menu.pressed.connect(onMenuPressed)
	btn_quit.pressed.connect(onQuitPressed)
	setup_audio_ui()
	setup_video_ui()
	pass # Replace with function body.

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_paused == false:
			if DialogSystem.isActive:
				return
			showPauseMenu()
			pass
		else:
			hidePauseMenu()
			pass
		get_viewport().set_input_as_handled()
	if is_paused:
		if event.is_action_pressed("right_bumper"):
			playAudio(button_focus_audio)
			changeTab(1)
			pass
		elif event.is_action_pressed("left_bumper"):
			playAudio(button_focus_audio)
			changeTab(-1)
			pass
	pass

func showPauseMenu() -> void:
	PlayerHud.hide()
	get_tree().paused = true
	visible = true
	is_paused = true
	shown.emit()
	%ArrowCountLabel.text = str(PlayerManager.player.arrow_count)
	%BombCountLabel.text = str(PlayerManager.player.bomb_count)
func hidePauseMenu() -> void:
	PlayerHud.show()
	get_tree().paused = false
	visible = false
	is_paused = false
	tab_container.current_tab = 0
	hidden.emit()

func onSavePressed() -> void:
	if is_paused == false:
		return
	SaveManager.saveGame()
	hidePauseMenu()
	pass

func onLoadPressed() -> void:
	playAudio(button_select_audio)
	if is_paused == false:
		return
	SaveManager.loadGame()
	await LevelManager.level_load_started
	hidePauseMenu()
	pass

func onQuitPressed() -> void:
	get_tree().quit()
	pass
func onMenuPressed() -> void:
	playAudio(button_select_audio)
	hidePauseMenu()
	LevelManager.load_new_level("res://Menu/Menu2/echoes_of_the_prophecy.gd.tscn","",Vector2(22.0,45.0))
	pass

#func updateItemDescription( newText : String ) -> void:
	#item_description.text = newText

func focusedItemChanged(slot: SlotData) -> void:
	if slot and slot.item_data:
		# Send the whole ItemData object to our new panel
		item_description_panel.update_info(slot.item_data)
		previewStats(slot.item_data)
	else:
		# Clear it if hovering an empty slot
		item_description_panel.clear_info()
		previewStats(null)
	pass

func playerAudio( _audio : AudioStream) -> void:
	audio_stream_player.stream = _audio 
	audio_stream_player.play()
	pass
func changeTab(_i : int = 1) -> void:
	tab_container.current_tab = wrapi(
		tab_container.current_tab + _i,
		0,
		tab_container.get_tab_count()
	) 
	tab_container.get_tab_bar().grab_focus()
	pass

func previewStats(item : ItemData ) -> void:
	preview_stats_change.emit(item)
	pass

func playAudio(_a : AudioStream) -> void:
	audio.stream = _a
	audio.play()
	pass
func updateAbilityItems( items : Array[String] ) -> void :
	var  item_buttons : Array[Node] = %AbilityGridContainer.get_children()
	for i in item_buttons.size():
		if items[i] == "":
			item_buttons[i].visible = false
		else:
			item_buttons[i].visible = true 
	pass

func setup_audio_ui() -> void:
	is_setting_up_ui = true # BLOCK SAVING
	
	# Get linear values (0 to 1) from the db
	var master_lin = db_to_linear(AudioServer.get_bus_volume_db(0))
	var music_lin = db_to_linear(AudioServer.get_bus_volume_db(1))
	var sfx_lin = db_to_linear(AudioServer.get_bus_volume_db(2))
	
	# If the bus is muted, force the slider to 0 visually
	if AudioServer.is_bus_mute(0): master_lin = 0.0
	if AudioServer.is_bus_mute(1): music_lin = 0.0
	if AudioServer.is_bus_mute(2): sfx_lin = 0.0

	master_slider.value = master_lin
	music_slider.value = music_lin
	sfx_slider.value = sfx_lin
	
	master_slider.value_changed.connect(on_master_changed)
	music_slider.value_changed.connect(on_music_changed)
	sfx_slider.value_changed.connect(on_sfx_changed)
	
	is_setting_up_ui = false # ALLOW SAVING AGAIN
# --- SIGNAL CALLBACKS ---
	pass
func on_master_changed(value : float) -> void:
	set_bus_volume("Master", value)
	GlobalManager.save_settings()
	pass
func on_music_changed(value : float) -> void:
	set_bus_volume("Music", value)
	GlobalManager.save_settings()
	pass
func on_sfx_changed(value : float) -> void:
	set_bus_volume("SFX", value)
	GlobalManager.save_settings()
	# Optional: Play a test sound only when releasing the mouse?
	# Or just rely on button hovers to hear the volume change.
	pass
func set_bus_volume(bus_name : String, value : float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	
	if value < 0.05:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	
	# Only save if the player actually moved the slider, not during setup
	if not is_setting_up_ui:
		GlobalManager.save_settings()
	pass

func setup_video_ui() -> void:
	# 1. SETUP WINDOW MODE DROPDOWN
	window_mode_btn.clear()
	window_mode_btn.add_item("Windowed", 0)
	window_mode_btn.add_item("Fullscreen", 1)
	
	# Check current mode to select the right option
	var current_mode = DisplayServer.window_get_mode()
	if current_mode == DisplayServer.WINDOW_MODE_WINDOWED:
		window_mode_btn.selected = 0
	else:
		window_mode_btn.selected = 1
		
	window_mode_btn.item_selected.connect(on_window_mode_selected)
	
	# 2. SETUP V-SYNC CHECKBOX
	# Check current status
	var current_vsync = DisplayServer.window_get_vsync_mode()
	vsync_btn.button_pressed = (current_vsync == DisplayServer.VSYNC_ENABLED)
	
	vsync_btn.toggled.connect(on_vsync_toggled)
	pass
# --- VIDEO CALLBACKS ---

func on_window_mode_selected(index: int) -> void:
	match index:
		0: # Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			# Optional: Center the window after switching back to windowed
			# DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	GlobalManager.save_settings()
	pass
func on_vsync_toggled(is_on: bool) -> void:
	if is_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	GlobalManager.save_settings()
	pass
