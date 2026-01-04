extends CanvasLayer

signal shown
signal hidden
signal preview_stats_change( item : ItemData )

@onready var audio_stream_player : AudioStreamPlayer = $Control/AudioStreamPlayer
@onready var tab_container: TabContainer = $Control/TabContainer
@export var button_select_audio : AudioStream = preload("res://Menu/menu_select.wav")
@export var button_focus_audio : AudioStream = preload("res://Menu/menu_focus.wav")
@onready var btn_save : Button =  $Control/TabContainer/System/VBoxContainer/btn_save
@onready var btn_load : Button = $Control/TabContainer/System/VBoxContainer/btn_load
@onready var btn_quit: Button = $Control/TabContainer/System/VBoxContainer/btn_quit
@onready var btn_menu: Button = $Control/TabContainer/System/VBoxContainer/btn_menu
@onready var item_description : Label = $Control/TabContainer/Inventory/ItemDescription
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SfxSlider

var is_paused : bool = false
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
		elif event.is_action_pressed("left_bumper"):
			playAudio(button_focus_audio)
			changeTab(-1)
		

func showPauseMenu() -> void:
	get_tree().paused = true
	visible = true
	is_paused = true
	shown.emit()
	%ArrowCountLabel.text = str(PlayerManager.player.arrow_count)
	%BombCountLabel.text = str(PlayerManager.player.bomb_count)
func hidePauseMenu() -> void:
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

func onMenuPressed() -> void:
	playAudio(button_select_audio)
	hidePauseMenu()
	LevelManager.load_new_level("res://Menu/Menu2/FrierenTheJourneyBeyondMenu.tscn","",Vector2.ZERO)
	pass

func updateItemDescription( newText : String ) -> void:
	item_description.text = newText

func focusedItemChanged( slot : SlotData) -> void:
	if slot:
		if slot.item_data:
			updateItemDescription(slot.item_data.description)
			previewStats(slot.item_data)
	else :
		updateItemDescription("")
		previewStats(null)
	pass

func playerAudio( _audio : AudioStream) -> void:
	audio_stream_player.stream = _audio 
	audio_stream_player.play()

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

func updateAbilityItems( items : Array[String] ) -> void :
	var  item_buttons : Array[Node] = %AbilityGridContainer.get_children()
	for i in item_buttons.size():
		if items[i] == "":
			item_buttons[i].visible = false
		else:
			item_buttons[i].visible = true 
	pass

func setup_audio_ui() -> void:
	# 1. Get current values from the AudioServer so sliders match reality
	# db_to_linear converts (-db) back to (0.0 - 1.0)
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0)) # 0 is Master
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(1))  # 1 is Music (usually)
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(2))    # 2 is SFX
	
	# 2. Connect Signals
	master_slider.value_changed.connect(on_master_changed)
	music_slider.value_changed.connect(on_music_changed)
	sfx_slider.value_changed.connect(on_sfx_changed)
	pass
# --- SIGNAL CALLBACKS ---

func on_master_changed(value : float) -> void:
	set_bus_volume("Master", value)
	pass
func on_music_changed(value : float) -> void:
	set_bus_volume("Music", value)
	pass
func on_sfx_changed(value : float) -> void:
	set_bus_volume("SFX", value)
	# Optional: Play a test sound only when releasing the mouse?
	# Or just rely on button hovers to hear the volume change.
	pass
func set_bus_volume(bus_name : String, value : float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	
	# Check if value is near 0 to mute completely
	if value < 0.05:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		# linear_to_db converts (0.5) -> (-6dB)
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	pass
