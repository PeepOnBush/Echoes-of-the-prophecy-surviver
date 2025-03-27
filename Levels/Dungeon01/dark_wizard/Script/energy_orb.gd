class_name EnergyOrb extends Node2D

@export var speed : float = 200
@export var shoot_audio : AudioStream
@export var hit_audio : AudioStream

var direction : Vector2 = Vector2.DOWN

@onready var hurt_box: HurtBox = $HurtBox
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hurt_box.did_damage.connect(hitPlayer)
	playAudio(shoot_audio)
	get_tree().create_timer(5).timeout.connect(destroy)
	direction = global_position.direction_to(PlayerManager.player.global_position)
	flicker()
	pass # Replace with function body.

func hitPlayer() -> void:
	playAudio(hit_audio)
	hurt_box.set_deferred("monitoring",false)
	pass

func flicker() -> void:
	modulate.a = randf() * 0.7 + 0.3
	await get_tree().create_timer(0.05).timeout
	flicker()
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction* speed * delta
	pass

func playAudio( _a : AudioStream) -> void:
	audio.stream = _a
	audio.play()

func destroy() -> void:
	queue_free()
