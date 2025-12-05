@tool
class_name CutsceneActionMusic extends CutsceneAction

@export var track : AudioStream
@export var reset_after_cutscene : bool = true

var original_track : AudioStream

func _ready() -> void:
	pass

func play() -> void:
	if reset_after_cutscene:
		original_track = AudioManager.getCurrentTrack()
		DialogSystem.finished.connect(_onCutsceneFinished)
	AudioManager.playMusic(track)
	finished.emit()
	pass
func _onCutsceneFinished() -> void:
	AudioManager.playMusic(original_track)
	pass
