class_name QuestsUI extends Control

const QUEST_ITEM : PackedScene = preload("res://GUI/pause_menu/quests/QuestItem.tscn")
const QUEST_STEP_ITEM : PackedScene = preload("res://GUI/pause_menu/quests/QuestStepItem.tscn")

@onready var quest_item_container : VBoxContainer = $ScrollContainer/MarginContainer/VBoxContainer
@onready var details_container: VBoxContainer = $VBoxContainer
@onready var quest_title: Label = $VBoxContainer/QuestTitle
@onready var description_label: Label = $VBoxContainer/DescriptionLabel



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clearQuestDetails()
	visibility_changed.connect(onVisibleChanged)
	pass # Replace with function body.

func onVisibleChanged() -> void:
	for i in quest_item_container.get_children():
		i.queue_free()
	
	clearQuestDetails()
	
	if visible:
		QuestManager.sortQuest()
		for q in QuestManager.curret_quests:
			var quest_data : Quest = QuestManager.findQuestByTitle(q.title)
			if quest_data == null:
				continue
			var new_q_item : QuestItem = QUEST_ITEM.instantiate()
			quest_item_container.add_child(new_q_item)
			new_q_item.initialize(quest_data, q)
			new_q_item.focus_entered.connect(updateQuestDetails.bind(new_q_item.quest))

func updateQuestDetails(q : Quest) -> void:
	clearQuestDetails()
	
	quest_title.text = q.title
	description_label.text = q.description
	
	var quest_save = QuestManager.findQuest(q)
	
	for step in q.steps:
		var new_step : QuestStepItem = QUEST_STEP_ITEM.instantiate()
		var step_is_complete : bool = false
		if quest_save.title != "not found":
			step_is_complete = quest_save.completed_steps.has(step.to_lower())
		details_container.add_child(new_step)
		new_step.initialize(step,step_is_complete) 
	
	pass

func clearQuestDetails() -> void:
	quest_title.text = ""
	description_label.text = ""
	for c in details_container.get_children():
		if c is QuestStepItem:
			c.queue_free()
	pass
