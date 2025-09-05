extends CanvasLayer

@export var button_focus_audio : AudioStream = preload("res://Menu/menu_focus.wav")
@export var button_select_audio : AudioStream = preload("res://Menu/menu_select.wav")

var hearts : Array[HeartGui] = []
@onready var game_over: Control = $Control/GameOver
@onready var title_button: Button = $Control/GameOver/VBoxContainer/TitleButton
@onready var continue_button: Button = $Control/GameOver/VBoxContainer/ContinueButton
@onready var animation_player: AnimationPlayer = $Control/GameOver/AnimationPlayer
@onready var audio : AudioStreamPlayer = $AudioStreamPlayer

@onready var boss_ui: Control = $Control/BossUI
@onready var boss_hp_bar: TextureProgressBar = $Control/BossUI/TextureProgressBar
@onready var boss_label: Label = $Control/BossUI/Label
@onready var notifcation: NotificationUI = $Control/Notifcation

@onready var abilities: Control = $Control/Abilities
@onready var ability_items : HBoxContainer = $Control/Abilities/HBoxContainer
@onready var arrow_count_label: Label = %ArrowCountLabel
@onready var bomb_count_label: Label = %BombCountLabel


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
	hideBossHealth()
	
	updateAbilityUI(0)
	PauseMenu.shown.connect(onShowPauseMenu)
	PauseMenu.hidden.connect(onHidePauseMenu)
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
	hideBossHealth()
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

func showBossHealth( boss_name : String ) -> void:
	boss_ui.visible = true
	boss_label.text = boss_name
	updateBossHealth(1,1)
	pass

func hideBossHealth() -> void:
	boss_ui.visible = false
	pass

func updateBossHealth( hp : int, max_hp : int ) -> void:
	boss_hp_bar.value = clampf( float(hp) / float(max_hp) * 100, 0, 100)
	pass

func queueNotification(_title : String , _message : String) -> void:
	notifcation.addNotificationToQueue(_title,_message)
	pass

func updateAbilityItem(items : Array[String]) -> void:
	@warning_ignore("confusable_local_usage", "shadowed_variable")
	var  ability_items : Array[Node] = ability_items.get_children()
	for i in ability_items.size():
		if items[i] == "":
			ability_items[i].visible = false
		else:
			ability_items[i].visible = true 
	pass

func  updateAbilityUI(ability_index : int ) -> void:
	var _items : Array[Node] = ability_items.get_children()
	for a in _items:
		a.self_modulate = Color(1,1,1,0)
		a.modulate = Color(0.6,0.6,0.6,0.8)
	_items[ability_index].self_modulate = Color(1,1,1,1)
	_items[ability_index].modulate = Color(1,1,1,1)
	playAudio(button_focus_audio)
	pass

func update_arrow_count( count : int ) -> void:
	arrow_count_label.text = str(count)
	pass

func update_bomb_count( count : int ) -> void:
	bomb_count_label.text = str(count)
	pass

func onShowPauseMenu() -> void:
	abilities.visible = false
	pass

func onHidePauseMenu() -> void:
	abilities.visible = true
	pass
