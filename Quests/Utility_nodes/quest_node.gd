@tool
class_name QuestNode extends Node2D

@export var linked_quest : Quest = null : set = setQuest
@export var quest_step : int = 0 : set = setStep
@export var quest_complete : bool = false : set = setComplete

@export_category("Information only")
@export_multiline var setting_summary : String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setQuest(_v : Quest) -> void:
	linked_quest = _v
	quest_step = 0
	updateSummary()
	pass

func setStep(_v : int) -> void:
	quest_step = clamp(_v,0,getStepCount())
	updateSummary()
	pass

func setComplete(_v : bool) -> void:
	quest_complete = _v
	updateSummary()
	pass

func getStepCount() -> int:
	if linked_quest == null:
		return 0
	else:
		return linked_quest.steps.size()

func updateSummary() -> void:
	setting_summary = "UPDATE QUEST:\nQuest: " + linked_quest.title + "\n"
	setting_summary += "Step: " + str(quest_step) + " - " + getStep() + "\n"
	setting_summary += "Complete: " + str(quest_complete	)
	pass

func getStep() -> String:
	if quest_step != 0 and quest_step <= getStepCount():
		return linked_quest.steps[ quest_step - 1 ].to_lower()
	else:
		return "N/A"
