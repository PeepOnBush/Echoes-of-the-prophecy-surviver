extends CanvasLayer

@export var button_focus_audio : AudioStream = preload("res://Menu/menu_focus.wav")
@export var button_select_audio : AudioStream = preload("res://Menu/menu_select.wav")

var hearts : Array[HeartGui] = []
var bars_original_pos: Vector2

@onready var game_over: Control = $Control/GameOver
@onready var title_button: Button = $Control/GameOver/VBoxContainer/TitleButton
@onready var continue_button: Button = $Control/GameOver/VBoxContainer/ContinueButton
@onready var animation_player: AnimationPlayer = $Control/GameOver/AnimationPlayer
@onready var audio : AudioStreamPlayer = $AudioStreamPlayer
@onready var timer_label: Label = $Control/TimerLabel
@onready var health_bar: TextureProgressBar = $Control/VBoxContainer/HealthBar
@onready var stamina_bar: TextureProgressBar = $Control/VBoxContainer/StaminaBar
@onready var v_box_container: VBoxContainer = $Control/VBoxContainer
@onready var boss_ui: Control = $Control/BossUI
@onready var boss_hp_bar: TextureProgressBar = $Control/BossUI/TextureProgressBar
@onready var boss_label: Label = $Control/BossUI/Label
@onready var notifcation: NotificationUI = $Control/Notifcation

@onready var abilities: Control = $Control/Abilities
@onready var ability_items : HBoxContainer = $Control/Abilities/HBoxContainer
@onready var arrow_count_label: Label = %ArrowCountLabel
@onready var bomb_count_label: Label = %BombCountLabel
# --- COMBO SYSTEM ---
@export_category("Combo System")
@export var combo_sounds: Array[AudioStream] # Drag your 5-10 sounds here!
@export var combo_timeout: float = 3.0 # How many seconds before combo resets

@onready var combo_container: Control = $Control/ComboContainer
@onready var combo_label: Label = $Control/ComboContainer/Label

var current_combo: int = 0
var combo_timer: Timer

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
	await get_tree().process_frame 
	bars_original_pos = v_box_container.position
	setup_combo_system()
	pass

#func updateHp(_hp : int, _maxHP : int) -> void:
	#updateMaxHp(_maxHP)
	#for i in _maxHP :
		#updateHeart(i,_hp)
	#pass

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

# --- NEW HP LOGIC ---
func updateHp(_hp : int, _maxHP : int) -> void:
	# Update Max
	health_bar.max_value = _maxHP
	
	# 2. DETECT DAMAGE
	# If the new HP is lower than what the bar currently shows, it's damage.
	if _hp < health_bar.value:
		shake_container() # <--- CALL THE SHAKE
	
	# Smoothly animate the value
	update_bar_smoothly(health_bar, _hp)
	pass
func shake_container() -> void:
	var tween = create_tween()
	var shake_power = 5.0 
	
	# Parallel: Do the shake AND the color flash at the same time
	tween.set_parallel(true)
	
	# 1. Flash Red
	health_bar.modulate = Color(10, 10, 10) # Flash pure white/bright
	tween.tween_property(health_bar, "modulate", Color.WHITE, 0.3)
	
	# 2. Shake (Must disable parallel to make these sequential steps, 
	#    or just use a second tween for position)
	var pos_tween = create_tween()
	for i in 5:
		var _offset = Vector2(randf_range(-shake_power, shake_power), randf_range(-shake_power, shake_power))
		pos_tween.tween_property(v_box_container, "position", bars_original_pos + _offset, 0.05)
	pos_tween.tween_property(v_box_container, "position", bars_original_pos, 0.05)
	pass
# --- NEW STAMINA LOGIC ---
func updateStamina(_current : float, _max : float) -> void:
	stamina_bar.max_value = _max
	# Stamina changes fast, so maybe we don't tween, or we tween very fast
	stamina_bar.value = _current

# Helper function to tween bars
func update_bar_smoothly(bar: TextureProgressBar, new_value: int) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(bar, "value", new_value, 0.2) # 0.2s duration
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
	pass

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

func update_timer(time_in_seconds: float) -> void:
	var minutes = int(time_in_seconds / 60)
	var seconds = int(time_in_seconds) % 60
	
	# Format to show 01:05 instead of 1:5
	timer_label.text = "%02d:%02d" % [minutes, seconds]

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
func setup_combo_system() -> void:
	# 1. Hide initially
	combo_container.visible = false
	combo_container.scale = Vector2(1, 1)
	
	# 2. Create internal timer
	combo_timer = Timer.new()
	add_child(combo_timer)
	combo_timer.wait_time = combo_timeout
	combo_timer.one_shot = true
	combo_timer.timeout.connect(reset_combo)
	
	# 3. Listen for kills
	PlayerManager.enemy_defeated.connect(on_enemy_killed)
func on_enemy_killed() -> void:
	# 1. Logic
	current_combo += 1
	combo_timer.start() # Reset the countdown
	combo_container.visible = true
	
	# 2. Visuals (Update Text)
	combo_label.text = "x" + str(current_combo)
	
	# 3. The "Pop" Effect (Tween)
	# We kill any running tween so it doesn't glitch if you hit fast
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC) # Makes it bouncy
	tween.set_ease(Tween.EASE_OUT)
	
	# Scale UP to 1.5x, then back DOWN to 1.0x
	combo_container.scale = Vector2(1.5, 1.5) 
	tween.tween_property(combo_container, "scale", Vector2(1.0, 1.0), 0.3)
	
	# 4. The Audio Logic (Array Indexing)
	if combo_sounds.size() > 0:
		# Logic: If combo is 1, use index 0. 
		# If combo > array size, use the LAST sound.
		var sound_index = min(current_combo - 1, combo_sounds.size() - 1)
		var sound_to_play = combo_sounds[sound_index]
		
		# Play using your Global Audio Manager
		AudioManager.play_sfx(sound_to_play)

func reset_combo() -> void:
	current_combo = 0
	
	# Optional: Fade out instead of instant disappear
	var tween = create_tween()
	tween.tween_property(combo_container, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func(): 
		combo_container.visible = false
		combo_container.modulate.a = 1.0 # Reset for next time
	)
	pass
