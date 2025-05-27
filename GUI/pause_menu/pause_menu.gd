extends CanvasLayer

signal shown
signal hidden
signal preview_stats_change( item : ItemData )

@onready var audio_stream_player : AudioStreamPlayer = $Control/AudioStreamPlayer
@onready var tab_container: TabContainer = $Control/TabContainer

@onready var btn_save : Button =  $Control/TabContainer/System/VBoxContainer/btn_save
@onready var btn_load : Button = $Control/TabContainer/System/VBoxContainer/btn_load
@onready var btn_quit: Button = $Control/TabContainer/System/VBoxContainer/btn_quit
@onready var item_description : Label = $Control/TabContainer/Inventory/ItemDescription

var is_paused : bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	hidePauseMenu()
	btn_save.pressed.connect(onSavePressed)
	btn_load.pressed.connect(onLoadPressed)
	btn_quit.pressed.connect(onQuitPressed)
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
			#change tab
			changeTab(1)
		elif event.is_action_pressed("left_bumper"):
			#change tab
			changeTab(-1)
		

func showPauseMenu() -> void:
	get_tree().paused = true
	visible = true
	is_paused = true
	shown.emit()

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
	if is_paused == false:
		return
	SaveManager.loadGame()
	await LevelManager.level_load_started
	hidePauseMenu()
	pass

func onQuitPressed() -> void:
	get_tree().quit()

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

func playerAudio( audio : AudioStream) -> void:
	audio_stream_player.stream = audio 
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
