#QUEST MANAGER - GLOBAL SCRIPT
extends Node

signal quest_updated(q)

const QUEST_DATA_LOCATION : String = "res://Quests/"

var quests : Array[Quest]
var curret_quests : Array = [
	#{ title = "Return lost magical flute", is_complete = false, completed_steps = [''] },
	#{ title = "Basic task", is_complete = false, completed_steps = [''] }
]
func _ready() -> void:
	#gather all quests
	gatherQuestData()
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		#print(findQuest(load("res://Quests/Return_lost_flute.tres") as Quest))
		#print(findQuestByTitle("Tutorial"))
		#print("getQuestIndexByTitle:" , getQuestIndexByTitle("Return lost magical flute"))
		#print("getQuestIndexByTitle:" , getQuestIndexByTitle("Tutorial"))
		print("before : " ,curret_quests)
		updateQuest("Return lost magical flute")
		updateQuest("Return lost magical flute","",true)
		updateQuest("Tutorial")
		updateQuest("Tutorial","Complete the quest")
		updateQuest("Tutorial", "", true)
		print("\n")
		updateQuest("Basic task")
		updateQuest("Basic task", "Step 1")
		updateQuest("Basic task", "Step 2")
		print("quests : " , curret_quests)
		#print("=========================================")
		pass
	pass

func gatherQuestData() -> void:
	var quest_files : PackedStringArray = DirAccess.get_files_at(QUEST_DATA_LOCATION)
	quests.clear()
	for q in quest_files: #add if statement to check if quests item is quest resource or not if folder contain different components
		quests.append(load(QUEST_DATA_LOCATION + "/" + q) as Quest)
		pass
	print("quests count: ",quests.size())
	pass

func updateQuest(_title : String, _completed_step : String = "", _is_complete : bool = false) -> void:
	#Update the status of a quest
	var quest_index : int = getQuestIndexByTitle(_title)
	if quest_index == -1:
		#quest was not found - add it to the current quests array
		var new_quest : Dictionary = {
			 title = _title,
			 is_complete = _is_complete,
			 completed_steps = []
		}
		
		if _completed_step != "":
			new_quest.completed_steps.append(_completed_step.to_lower())
		
		curret_quests.append(new_quest)
		quest_updated.emit(new_quest)
		#display a notif that quests was added
		PlayerHud.queueNotification("Quest Started", _title)
		pass
	else:
		#Quest was found, update it
		var q = curret_quests[quest_index]
		if _completed_step != "" and q.completed_steps.has(_completed_step) == false:
			q.completed_steps.append(_completed_step.to_lower())
			pass
		q.is_complete = _is_complete
		quest_updated.emit(q)
		#Display a notif that quests was updated or completed
		if q.is_complete == true:
			PlayerHud.queueNotification("Quest Complete!", _title)
			distributeQuestRewards(findQuestByTitle(_title)) 
		else:
			PlayerHud.queueNotification("Quest Updated", _title + ": " + _completed_step)
	pass

func distributeQuestRewards(_q : Quest) -> void:
	#Give XP and items rewards to player
	var _message : String = str(_q.reward_xp) + "xp"
	PlayerManager.rewardXP(_q.reward_xp)
	for i in _q.reward_items:
		_message += ", " + i.item.name + " x" + str(i.quantity)
		PlayerManager.INVENTORY_DATA.add_item(i.item, i.quantity)
		
	PlayerHud.queueNotification("Quest Rewards Received!", _message )
	pass

#Provide a quest and return the current quest associated with it
func findQuest(_quest : Quest) -> Dictionary:
	for q in curret_quests:
		if q.title.to_lower() == _quest.title.to_lower():
			return q 
	return { title = "not found", is_complete = false, completed_steps = [''] }

func findQuestByTitle(_title : String) -> Quest:
	#take title and find associated quest resource
	for q in quests:
		if q.title.to_lower() == _title.to_lower():
			return q 
	return null

func getQuestIndexByTitle( _title : String) -> int:
	for i in curret_quests.size():
		if curret_quests[i].title.to_lower() == _title.to_lower():
			return i
	#return -1 if nothing was found
	return -1


func sortQuest() -> void:
	var active_quests : Array = []
	var completed_quests : Array = []
	for q in curret_quests:
		if q.is_complete:
			completed_quests.append( q )
		else:
			active_quests.append( q )
	
	active_quests.sort_custom( sort_quests_ascending )
	completed_quests.sort_custom( sort_quests_ascending )
	
	curret_quests = active_quests
	curret_quests.append_array( completed_quests )
	pass


func sort_quests_ascending( a, b ):
	if a.title < b.title:
		return true
	return false
