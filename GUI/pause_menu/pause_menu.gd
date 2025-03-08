extends CanvasLayer

signal shown
signal hidden

@onready var audio_stream_player : AudioStreamPlayer = $AudioStreamPlayer
@onready var btn_save : Button =  $Control/HBoxContainer/btn_save
@onready var btn_load : Button = $Control/HBoxContainer/btn_load
@onready var item_description : Label = $Control/ItemDescription

var is_paused : bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	hidePauseMenu()
	btn_save.pressed.connect(onSavePressed)
	btn_load.pressed.connect(onLoadPressed)
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

func showPauseMenu() -> void:
	get_tree().paused = true
	visible = true
	is_paused = true
	shown.emit()

func hidePauseMenu() -> void:
	get_tree().paused = false
	visible = false
	is_paused = false
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

func updateItemDescription( newText : String ) -> void:
	item_description.text = newText


func playerAudio( audio : AudioStream) -> void:
	audio_stream_player.stream = audio 
	audio_stream_player.play()
