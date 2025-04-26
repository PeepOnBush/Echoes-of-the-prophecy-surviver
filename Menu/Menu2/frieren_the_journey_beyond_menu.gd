extends Node2D

const START_LEVEL : String = "res://Levels/Area01/01.tscn"

@export var music : AudioStream
@export var button_focus_audio : AudioStream
@export var button_press_audio : AudioStream

@onready var button_new: Button = $CanvasLayer/Control/ButtonNew
@onready var button_continue: Button = $CanvasLayer/Control/ButtonContinue
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	get_tree().paused = true
	PlayerManager.player.visible = false
	PlayerHud.visible = false
	PauseMenu.process_mode = Node.PROCESS_MODE_DISABLED
	if SaveManager.getSaveFile() == null:
		button_continue.disabled = true
	
	setupTileScreen()
	
	LevelManager.level_load_started.connect(exitTitleScreen)
	pass # Replace with function body.




func setupTileScreen() -> void:
	button_new.pressed.connect( startGame)
	button_continue.pressed.connect(loadGame) 
	button_new.grab_focus()
	
	button_new.focus_entered.connect(playAudio.bind(button_focus_audio))
	button_continue.focus_entered.connect(playAudio.bind(button_focus_audio))
	pass

func startGame() -> void:
	AudioManager.playMusic(music)
	playAudio(button_press_audio)
	LevelManager.load_new_level(START_LEVEL,"",Vector2.ZERO)
	pass

func loadGame() -> void:
	SaveManager.loadGame()
	playAudio(button_press_audio)
	PlayerHud.boss_hp_bar.visible = false
	pass

func exitTitleScreen() -> void:
	PlayerManager.player.visible = true
	PlayerHud.visible = true
	PauseMenu.process_mode = Node.PROCESS_MODE_ALWAYS
	self.queue_free()
	pass

func playAudio(_a : AudioStream) -> void:
	audio_stream_player.stream = _a
	audio_stream_player.play()
