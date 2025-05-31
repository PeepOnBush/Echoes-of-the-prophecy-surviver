extends CanvasLayer

signal shown
signal hidden

@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

const ERROR = preload("res://GUI/shop_menu/Audio/error.wav")
const OPEN_SHOP = preload("res://GUI/shop_menu/Audio/open_shop.wav")
const PURCHASE = preload("res://GUI/shop_menu/Audio/purchase.wav")


@onready var close_button: Button = %CloseButton

var is_active : bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hideMenu()
	close_button.pressed.connect(hideMenu)
	pass

func _unhandled_input(event: InputEvent) -> void:
	if is_active == false:
		return
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		hideMenu()



func showMenu(items : Array[ItemData],dialog_triggered : bool = true) -> void:
	print(items,items.size())
	if dialog_triggered:
		await DialogSystem.finished
	enabledMenu()
	playAudio(OPEN_SHOP)
	shown.emit()
	pass

func hideMenu() -> void:
	enabledMenu(false)
	hidden.emit()
	pass

func enabledMenu(_enabled : bool = true) -> void:
	get_tree().paused = _enabled
	visible = _enabled
	is_active = _enabled
	pass

func playAudio(_audio : AudioStream) -> void:
	audio.stream = _audio
	audio.play()
	pass
