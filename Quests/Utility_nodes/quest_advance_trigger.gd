@tool
@icon("res://Quests/Utility_nodes/Icons/quest_advance.png")
class_name QuestAdvanceTrigger extends QuestNode

signal advanced

@export_category("Parent Signal Connection")
@export var signal_name : String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if has_node("Sprite2D"):
		$Sprite2D.queue_free()
	if signal_name != "":
		if get_parent().has_signal(signal_name):
			get_parent().connect(signal_name, advanceQuest)
	pass # Replace with function body.

func advanceQuest() -> void:
	if linked_quest == null:
		return
	await get_tree().process_frame
	advanced.emit()
	var _title : String = linked_quest.title
	var _step : String = getStep()
	if _step == "N/A":
		_step = ""
	QuestManager.updateQuest(_title,_step,quest_complete)
	pass
