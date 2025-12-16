@tool
@icon("res://GUI/dialog_system/Icons/result_bubble.svg")
class_name DialogResultCommon extends DialogResult

enum ActionType { 
	GIVE_XP, 
	HEAL_PLAYER, 
	GIVE_ITEM, 
	PLAY_SOUND, 
	MODIFY_QUEST,
	REMOVE_PARENT_NPC
}

@export_category("Action Settings")
@export var action_type : ActionType = ActionType.GIVE_XP : set = set_type

@export_group("Parameters")
# We use export_storage logic (conditional visibility) if we want to get fancy, 
# but for now, listing them is fine.
@export var int_amount : int = 0
@export var item_data : ItemData
@export var audio_clip : AudioStream
@export var string_data : String = "" # Quest Name or Tag

func _ready():
	super()
	if Engine.is_editor_hint():
		update_name()

func _on_execute() -> void:
	match action_type:
		ActionType.GIVE_XP:
			PlayerManager.rewardXP(int_amount)
			AudioManager.play_sfx(audio_clip)
			print("Gave XP: ", int_amount)
			
		ActionType.HEAL_PLAYER:
			AudioManager.play_sfx(audio_clip)
			PlayerManager.player.update_hp(int_amount)
			print("Healed: ", int_amount)
			
		ActionType.GIVE_ITEM:
			if item_data:
				PlayerManager.INVENTORY_DATA.add_item(item_data, int_amount)
				AudioManager.play_sfx(audio_clip)
				# Trigger a notification UI here if you want
				
		ActionType.PLAY_SOUND:
			if audio_clip:
				AudioManager.play_sfx(audio_clip) # Assuming you made this function
				
		ActionType.MODIFY_QUEST:
			# Example: Update a quest step
			AudioManager.play_sfx(audio_clip)
			QuestManager.updateQuest(string_data, "step_complete", true)
			
		ActionType.REMOVE_PARENT_NPC:
			var p = get_parent()
			while p != null:
				if p is NPC:
					p.queue_free()
					break
				p = p.get_parent()

# --- EDITOR VISUALIZATION (Optional) ---
# This changes the node name in the tree so you can read what it does!
func set_type(value):
	action_type = value
	update_name()


func update_name():
	if Engine.is_editor_hint():
		name = "Do: " + ActionType.keys()[action_type]
