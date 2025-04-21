@tool
@icon("res://Quests/Utility_nodes/Icons/quest_switch.png")
class_name QuestActivatedSwitch extends QuestNode

enum CheckType{ HAS_QUEST, QUEST_STEP_COMPLETE, ON_CURRENT_QUEST_STEP, QUEST_COMPLETE }

signal is_activated_changed( v : bool )

@export var check_type : CheckType = CheckType.HAS_QUEST : set = setCheckType
@export var remove_when_activated : bool = false
@export var react_to_global_signal : bool = false

var is_activated : bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	$Sprite2D.queue_free()
	if react_to_global_signal == true:
		QuestManager.quest_updated.connect(onQuestUpdated)
	checkIsActivated()
	pass


func onQuestUpdated(_q : Dictionary) -> void:
	checkIsActivated()
	pass

func checkIsActivated() -> void:
	#get the save quest
	var _q : Dictionary = QuestManager.findQuest(linked_quest)
	
	if _q.title != "not found":
		
		if check_type == CheckType.HAS_QUEST:
			#we already pass this test, so we're done
			setIsActivated(true)
		
		elif check_type == CheckType.QUEST_COMPLETE:
			#simply test is activated based on if our quest complete values match
			var is_complete : bool = false
			if _q.is_complete is bool:
				is_complete = _q.is_complete
			setIsActivated(is_complete)
		
		elif check_type == CheckType.QUEST_STEP_COMPLETE:
			
			if quest_step > 0:
				if _q.completed_steps.has( getStep() ) == true:
					setIsActivated(true)
				else:
					setIsActivated(false)
			else:
				setIsActivated(false)
		
		elif check_type == CheckType.ON_CURRENT_QUEST_STEP:
			var step : String = getStep()
			if step == "N/A":
				setIsActivated(false)
				pass
			else:
				if _q.completed_steps.has(step):
					setIsActivated(false)
				else:
					var prev_step : String = getPrevStep()
					if prev_step == "N/A":
						setIsActivated(true)
					
					elif _q.completed_steps.has(prev_step.to_lower()):
						setIsActivated(true)
					else:
						setIsActivated(false)
			pass
		pass
	else:
		setIsActivated(false)
	
	pass


func setIsActivated(_v : bool ) -> void:
	is_activated = _v
	is_activated_changed.emit( _v )
	if is_activated == true:
		if remove_when_activated == true:
			hideChildren()
		else:
			showChildren()
	else:
		if remove_when_activated == true:
			showChildren()
		else:
			hideChildren()
	pass

func showChildren() -> void:
	for c in get_children():
		c.visible = true
		c.process_mode = Node.PROCESS_MODE_INHERIT

func hideChildren() -> void:
	for c in get_children():
		c.set_deferred("visible", false)
		c.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)



func updateSummary() -> void:
	if linked_quest == null:
		setting_summary = "Select a quest"
		return 
	setting_summary = "UPDATE QUEST:\nQuest: " + linked_quest.title + "\n"
	if check_type == CheckType.HAS_QUEST:
		setting_summary += "Checking if player has quest"
	elif check_type == CheckType.QUEST_STEP_COMPLETE:
		setting_summary += "Checking if player has completed step: " + getStep()
	elif check_type == CheckType.ON_CURRENT_QUEST_STEP:
		setting_summary += "Checking if player is on step: " + getStep()
	elif check_type == CheckType.QUEST_COMPLETE:
		setting_summary += "Checking if step is complete"
	pass

func setCheckType( v : CheckType) -> void:
	check_type = v
	updateSummary()
	pass
