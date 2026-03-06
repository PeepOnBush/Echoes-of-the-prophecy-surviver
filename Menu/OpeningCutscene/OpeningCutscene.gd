extends Control

# Path to your Main Menu
@export_file("*.tscn") var main_menu_scene : String = "res://Menu/Menu2/echoes_of_the_prophecy.gd.tscn"

@onready var anim_player : AnimationPlayer = $CanvasLayer/CutscenePlayer
@onready var music_player: AudioStreamPlayer = $CanvasLayer/MusicPlayer
@export var music : AudioStream

var transition_started : bool = false

func _ready() -> void:
	AudioManager.playMusic(music)
	# 1. HIDE THE PLAYER
	# We assume PlayerManager exists.
	if PlayerManager.player:
		PlayerManager.player.visible = false
		# Optional: Disable their physics so they don't fall/move
		PlayerHud.visible = false
	
	# 2. Start animation
	anim_player.play("IntroSequence")
	anim_player.animation_finished.connect(_on_animation_finished)

func _unhandled_input(event: InputEvent) -> void:
	# 3. Handle Skip
	if event.is_action_pressed("ui_accept"): # Enter / Space
		go_to_menu()

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "IntroSequence":
		go_to_menu()
		PlayerHud.visible = true

func go_to_menu() -> void:
	if transition_started: return
	transition_started = true
	
	# Optional: Fade out music if playing
	# var tween = create_tween()
	# tween.tween_property($MusicPlayer, "volume_db", -80, 1.0)
	
	# Change Scene
	# Since we are booting the game, we don't need the complex LoadingScreen logic yet,
	# but you can use LevelManager if you want the fade effect.
	get_tree().change_scene_to_file(main_menu_scene)
