extends CanvasLayer

@export var button_focus_audio : AudioStream = preload("res://Menu/menu_focus.wav")
@export var button_select_audio : AudioStream = preload("res://Menu/menu_select.wav")

var hearts : Array[HeartGui] = []
@onready var game_over: Control = $Control/GameOver
@onready var title_button: Button = $Control/GameOver/VBoxContainer/TitleButton
@onready var continue_button: Button = $Control/GameOver/VBoxContainer/ContinueButton
@onready var animation_player: AnimationPlayer = $Control/GameOver/AnimationPlayer
@onready var audio : AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	for child in $Control/HFlowContainer.get_children():
		if child is HeartGui:
			hearts.append(child)
			child.visible = false
	
	hideGameOverScreen()
	continue_button.focus_entered.connect(playAudio.bind(button_focus_audio))
	continue_button.pressed.connect(loadGame)
	title_button.focus_entered.connect(playAudio.bind(button_focus_audio))
	title_button.pressed.connect(titleScreen)
	LevelManager.level_load_started.connect(hideGameOverScreen)
	pass

func updateHp(_hp : int, _maxHP : int) -> void:
	updateMaxHp(_maxHP)
	for i in _maxHP :
		updateHeart(i,_hp)
	pass

func updateHeart(_index : int , _hp : int ) -> void:
	var _value : int = clampi(_hp - _index  * 2, 0 , 2)
	hearts[_index].value = _value
	pass
	
func updateMaxHp(_maxHP : int) -> void:
	var _heartCount : int  = roundi(_maxHP * 0.5)
	for i in hearts.size():
		if i < _heartCount:
			hearts[i].visible = true
		else :
			hearts[i].visible = false
	pass

func showGameOverScreen() -> void:
	game_over.visible = true
	game_over.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var can_continue : bool = SaveManager.getSaveFile() != null
	continue_button.visible = can_continue
	
	animation_player.play("show_game_over")
	await animation_player.animation_finished
	#focus a button
	
	if can_continue == true:
		continue_button.grab_focus()
	else:
		title_button.grab_focus()
	
	pass


func hideGameOverScreen() -> void:
	game_over.visible = false
	game_over.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_over.modulate = Color(1,1,1,0)
	pass

func playAudio(_a : AudioStream) -> void:
	audio.stream = _a
	audio.play()

func loadGame() -> void:
	playAudio(button_select_audio)
	await fadeToBlack()
	SaveManager.loadGame()
	pass

func titleScreen() -> void:
	playAudio(button_select_audio)
	await fadeToBlack()
	LevelManager.load_new_level("res://Menu/Menu2/FrierenTheJourneyBeyondMenu.tscn","",Vector2.ZERO)
	pass


func fadeToBlack() -> bool:
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	PlayerManager.player.revivePlayer()
	return true
