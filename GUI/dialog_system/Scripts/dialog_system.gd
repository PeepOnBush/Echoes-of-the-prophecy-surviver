@tool
@icon("res://GUI/dialog_system/Icons/star_bubble.svg") 
class_name DialogSystemNode extends CanvasLayer

signal started
signal finished
signal letter_added(letter :String)


var isActive : bool = false
var textInProgress : bool = false

var text_speed : float = 0.02
var text_length : int = 0
var plain_text : String

var dialog_items : Array[DialogItem]
var dialog_item_index : int = 0
var waiting_for_choice : bool = false 
var watching_cutsceen : bool = false


@onready var dialog_ui: Control = $DialogUi
@onready var content : RichTextLabel = $DialogUi/PanelContainer/RichTextLabel
@onready var name_label: Label = $DialogUi/NameLabel
@onready var potrait_sprite: DialogPotrait = $DialogUi/PotraitSprite
@onready var dialog_progress_indicator: PanelContainer = $DialogUi/DialogProgressIndicator
@onready var dialog_progress_indicator_label: Label = $DialogUi/DialogProgressIndicator/Label
@onready var audio_stream_player: AudioStreamPlayer = $DialogUi/AudioStreamPlayer
@onready var timer: Timer = $DialogUi/Timer
@onready var choice_options : VBoxContainer = $DialogUi/VBoxContainer


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
	if isActive == false or watching_cutsceen == true:
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
		elif waiting_for_choice == true:
			return
		
		advanceDialog()
	pass
## Show the dialog UI
func showDialog( _items : Array[ DialogItem ] ) -> void:
	isActive = true
	if _items:
		if _items[0] is DialogCutscene:
			dialog_ui.visible = false
		else:
			dialog_ui.visible = true
			
		for i in _items:
			if i is DialogCutscene:
				$CutsceneUi/AnimationPlayer.play("start")
	dialog_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	dialog_items = _items
	dialog_item_index = 0
	get_tree().paused = true
	await get_tree().process_frame
	started.emit()
	if dialog_items.size() == 0:
		hideDialog()
	else:
		startDialog()
	pass

func hideDialog() -> void:
	isActive = false
	choice_options.visible = false
	dialog_ui.visible = false
	dialog_ui.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false
	finished.emit()
	PlayerManager.resetCameraOnPlayer()
	$CutsceneUi/AnimationPlayer.play("end")
	pass

func startDialog() -> void:
	waiting_for_choice = false
	showDialogButtonIndicator(false)
	var _d : DialogItem = dialog_items[dialog_item_index]
	
	if _d is DialogText:
		setDialogText(_d as DialogText)
	elif _d is DialogChoice:
		setDialogChoice(_d as DialogChoice)
	elif _d is DialogCutscene:
		startDialogCutscene(_d as DialogCutscene)
	pass

func startDialogCutscene(_d : DialogCutscene) -> void:
	watching_cutsceen = true
	_d.play()
	choice_options.visible = false
	dialog_ui.visible = false
	await _d.finished
	watching_cutsceen = false
	choice_options.visible = true
	dialog_ui.visible = true
	advanceDialog()
	pass

func advanceDialog() -> void:
	dialog_item_index +=1
	if dialog_item_index < dialog_items.size():
		startDialog()
	else:
		hideDialog()
	pass

## set dialog and npc variables, etc based on dialog item parameters
## once set start text timer
func setDialogText( _d : DialogItem) -> void:
	content.text = _d.text
	choice_options.visible = false
	name_label.text = _d.npc_info.npc_name
	potrait_sprite.texture = _d.npc_info.portrait
	potrait_sprite.audio_pitch_base = _d.npc_info.dialog_audio_pitch
	content.visible_characters = 0
	text_length = content.get_total_character_count()
	plain_text = content.get_parsed_text()
	textInProgress = true
	startTimer()
	pass

func setDialogChoice(_d : DialogChoice) -> void:
	choice_options.visible = true
	waiting_for_choice = true
	for c in choice_options.get_children():
		c.queue_free()
	
	for i in _d.dialog_branches.size():
		var _new_choice : Button = Button.new()
		_new_choice.text = _d.dialog_branches[i].text
		_new_choice.pressed.connect( dialogChoiceSelected.bind(_d.dialog_branches[i]))
		choice_options.add_child(_new_choice)
	
	if Engine.is_editor_hint():
		return
	await get_tree().process_frame
	await get_tree().process_frame
	choice_options.get_child(0).grab_focus()
	pass


func dialogChoiceSelected(_d : DialogBranch) -> void:
	choice_options.visible = false
	_d.selected.emit()
	showDialog(_d.dialog_items)
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
