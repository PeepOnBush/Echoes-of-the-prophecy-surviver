@tool
@icon("res://GUI/dialog_system/Icons/cutscene_bubble.svg")
class_name DialogCutscene extends DialogItem

signal finished 

enum Mode { PARALLEL, SEQUENTIAL }

@export var playback_mode : Mode = Mode.SEQUENTIAL

var actions : Array[CutsceneAction] = []
var action_finished_count : int = 0

func _ready() -> void:
	gatherAction()
	pass

func gatherAction() -> void:
	for c in get_children():
		if c is CutsceneAction:
			actions.append(c)
			if Engine.is_editor_hint() == false:
				c.finished.connect(onActionFinished)
	pass

func play() -> void:
	if Engine.is_editor_hint():
		return
	action_finished_count = 0
	if actions.size() == 0:
		await get_tree().process_frame
		finished.emit()
	elif playback_mode == Mode.SEQUENTIAL:
		actions[0].play()
	else:
		for a in actions:
			a.play()
	pass


func onActionFinished() -> void:
	action_finished_count += 1
	if action_finished_count >= actions.size():
		finished.emit()
	elif playback_mode == Mode.SEQUENTIAL:
		actions[action_finished_count].play()
	pass
