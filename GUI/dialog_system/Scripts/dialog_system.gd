@tool
@icon("res://GUI/dialog_system/Icons/star_bubble.svg") 
class_name DialogSystemNode extends CanvasLayer

signal finished
signal letter_added(letter :String)


var isActive : bool = false
var textInProgress : bool = false

var text_speed : float = 0.02
var text_length : int = 0
var plain_text : String

var dialog_items : Array[DialogItem]
var dialog_item_index : int = 0

@onready var dialog_ui: Control = $DialogUi
@onready var content : RichTextLabel = $DialogUi/PanelContainer/RichTextLabel
@onready var name_label: Label = $DialogUi/NameLabel
@onready var potrait_sprite: DialogPotrait = $DialogUi/PotraitSprite
@onready var dialog_progress_indicator: PanelContainer = $DialogUi/DialogProgressIndicator
@onready var dialog_progress_indicator_label: Label = $DialogUi/DialogProgressIndicator/Label
@onready var audio_stream_player: AudioStreamPlayer = $DialogUi/AudioStreamPlayer
@onready var timer: Timer = $DialogUi/Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		if get_viewport() is Window:
			get_parent().remove_child(self)
			return
		return
	timer.timeout.connect( onTimerTimeout)
	hideDialog()
	pass


func _unhandled_input(event: InputEvent) -> void:
	if isActive == false:
		return
	if(
		event.is_action_pressed("interact") or 
		event.is_action_pressed("attack") or
		event.is_action_pressed("ui_accept")
	):
		if textInProgress == true :
			content.visible_characters = text_length
			timer.stop()
			textInProgress = false
			showDialogButtonIndicator(true)
			return
		dialog_item_index +=1
		if dialog_item_index < dialog_items.size():
			startDialog()
		else:
			hideDialog()
func showDialog( _items : Array[DialogItem] ) -> void:
	isActive = true
	dialog_ui.visible = true
	dialog_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	dialog_items = _items
	dialog_item_index = 0
	get_tree().paused = true
	await get_tree().process_frame
	startDialog()
	pass

func hideDialog() -> void:
	isActive = false
	dialog_ui.visible = false
	dialog_ui.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false
	finished.emit()
	pass

func startDialog() -> void:
	showDialogButtonIndicator(false)
	var _d : DialogItem = dialog_items[dialog_item_index]
	setDialogData(_d)
	
	content.visible_characters = 0
	text_length = content.get_total_character_count()
	plain_text = content.get_parsed_text()
	textInProgress = true
	startTimer()
	pass

func startTimer() -> void:
	timer.wait_time = text_speed
	#manipulate wait_time
	var _char = plain_text[content.visible_characters - 1]
	if '.,!?:;'.contains( _char):
		timer.wait_time *= 4
	elif ', '.contains( _char):
		timer.wait_time *= 2
	timer.start()
	pass

func onTimerTimeout() -> void:
	content.visible_characters +=1
	if content.visible_characters <= text_length:
		letter_added.emit(plain_text[content.visible_characters - 1])
		startTimer()
	else:
		showDialogButtonIndicator(true)
		textInProgress = false
	pass

func showDialogButtonIndicator( _isVisible : bool ) -> void:
	dialog_progress_indicator.visible = _isVisible
	if dialog_item_index + 1 < dialog_items.size():
		dialog_progress_indicator_label.text = "NEXT"
	else:
		dialog_progress_indicator_label.text = "END"
	pass

func setDialogData( _d : DialogItem) -> void:
	if _d is DialogText:
		content.text = _d.text
	name_label.text = _d.npc_info.npc_name
	potrait_sprite.texture = _d.npc_info.portrait
	potrait_sprite.audio_pitch_base = _d.npc_info.dialog_audio_pitch
	pass
