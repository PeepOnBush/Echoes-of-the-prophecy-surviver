@tool
@icon("res://GUI/dialog_system/Icons/result_bubble.svg")
class_name DialogResultCommon extends DialogResult

enum ActionType { 
	GIVE_XP, 
	HEAL_PLAYER, 
	GIVE_ITEM, 
	PLAY_SOUND, 
	MODIFY_QUEST,
	START_FISHING,
	OPEN_SHOP,
	OPEN_RECIPE_MENU,
	REMOVE_PARENT_NPC,
	CHANGE_SCENE
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
@export var entry_node_name : String = "PlayerSpawn" 

@export_group("Scene Transition")
@export_file("*.tscn") var target_scene : String = ""
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
		ActionType.START_FISHING:
			await get_tree().process_frame
			PlayerHud.start_fishing_minigame()
			pass
		ActionType.OPEN_SHOP:
			# Look for a ShopKeeper script on the NPC parent
			var npc = get_npc_parent()
			if npc and npc.has_method("open_shop_ui"):
				npc.open_shop_ui()
			else:
				printerr("Dialog Result: Parent NPC is not a ShopKeeper!")
			pass
		ActionType.OPEN_RECIPE_MENU:
			# Look for a KitchenShopKeeper script
			var npc = get_npc_parent()
			if npc and npc.has_method("open_kitchen_ui"):
				npc.open_kitchen_ui()
			else:
				printerr("Dialog Result: Parent NPC does not have a Kitchen!")
			pass
		ActionType.CHANGE_SCENE:
			if target_scene != "":
				DialogSystem.hideDialog()
				# FIX: Pass the entry_node_name, not a hardcoded string
				LevelManager.load_new_level(target_scene, entry_node_name, Vector2.ZERO)
			else:
				print("ERROR: No target scene set!")
	
# --- EDITOR VISUALIZATION (Optional) ---
# This changes the node name in the tree so you can read what it does!
func set_type(value):
	action_type = value
	update_name()


func update_name():
	if Engine.is_editor_hint():
		name = "Do:" + ActionType.keys()[action_type]

func get_npc_parent() -> Node:
	var p = get_parent()
	while p != null:
		# Check if it has the script methods we need
		if p.has_method("open_shop_ui") or p.has_method("open_kitchen_ui"):
			return p
		p = p.get_parent()
	return null
