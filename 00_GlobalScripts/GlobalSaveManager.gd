extends Node

const SAVE_PATH = "user://"

signal game_loaded
signal game_saved

var currentSave : Dictionary = {
	scene_path = "",
	player =  {
		level = 1,
		xp = 1,
		hp = 1,
		max_hp = 1,
		pos_x = 0,
		pos_y = 0,
		arrow_count = 0,
		bomb_count = 0,
		ricochet_amount = 0 # Track this specifically
	},
	# NEW: Meta Progression Data
	base_stats = {
		attack = 1,
		defense = 0,
		max_hp = 6
	},
	currency = 0,
	run_difficulty = 1,
	
	items = [],
	persistence = [],
	quests = [],
	abilities = ["", "", "", ""],
	
	# NEW: Store file paths of unlocked skills (Since we can't save Resource Objects directly)
	unlocked_upgrades = [] 
}

func saveGame() -> void:
	updatePlayerData()
	updateScenePath()
	updateItemData()
	updateQuestData()
	updateMetaProgression() # <--- NEW HELPER
	
	var file := FileAccess.open(SAVE_PATH + "save.sav", FileAccess.WRITE)
	var save_json = JSON.stringify(currentSave)
	file.store_line(save_json)
	game_saved.emit()

func getSaveFile() -> FileAccess:
	return FileAccess.open(SAVE_PATH + "save.sav", FileAccess.READ)

func loadGame() -> void:
	var file := getSaveFile()
	if not file:
		return
		
	var load_json = JSON.new()
	load_json.parse(file.get_line())
	var save_dict : Dictionary = load_json.get_data() as Dictionary
	currentSave = save_dict
	
	if currentSave.has("run_difficulty"):
		LevelManager.current_run_difficulty = currentSave.run_difficulty
		

	# 2. Re-Load Unlocked Shop Items
	if currentSave.has("unlocked_upgrades"):
		PlayerManager.unlocked_upgrades.clear()
		for path in currentSave.unlocked_upgrades:
			if ResourceLoader.exists(path):
				var upgrade_res = load(path)
				PlayerManager.unlocked_upgrades.append(upgrade_res)

	# 3. Load Level
	LevelManager.load_new_level(currentSave.scene_path, "", Vector2.ZERO)
	
	await LevelManager.level_load_started
	
	# 4. Apply Player Runtime Stats
	PlayerManager.set_player_position(Vector2(currentSave.player.pos_x, currentSave.player.pos_y))
	PlayerManager.set_health(currentSave.player.hp, currentSave.player.max_hp)
	
	var _p : Player = PlayerManager.player
	_p.level = currentSave.player.level
	_p.xp = currentSave.player.xp
	

	_p.arrow_count = currentSave.player.arrow_count
	_p.bomb_count = currentSave.player.bomb_count
	
	if currentSave.player.has("ricochet_amount"):
		_p.arrow_ricochet_amount = currentSave.player.ricochet_amount
	
	PlayerManager.INVENTORY_DATA.parseSaveData(currentSave.items)
	QuestManager.curret_quests = currentSave.quests
	
	# Update HUD/Inventory to match
	await LevelManager.level_loaded
	game_loaded.emit()

func updatePlayerData() -> void:
	var p : Player = PlayerManager.player
	currentSave.player.hp = p.hp
	currentSave.player.max_hp = p.max_hp
	currentSave.player.pos_x = p.global_position.x
	currentSave.player.pos_y = p.global_position.y
	currentSave.player.level = p.level
	currentSave.player.xp = p.xp
	
	# Save specific combat stats
	currentSave.player.arrow_count = p.arrow_count
	currentSave.player.bomb_count = p.bomb_count
	currentSave.player.ricochet_amount = p.arrow_ricochet_amount
	
	currentSave.abilities = p.player_abilities.abilities

func updateMetaProgression() -> void:
	# Save Global variables that live in PlayerManager/LevelManager
	#currentSave.currency = PlayerManager.currency
	currentSave.run_difficulty = LevelManager.current_run_difficulty
	
	# Convert Resource Objects -> String Paths for saving
	currentSave.unlocked_upgrades = []
	for upgrade in PlayerManager.unlocked_upgrades:
		currentSave.unlocked_upgrades.append(upgrade.resource_path)

func updateScenePath() -> void:
	var p : String = ""
	for c in get_tree().root.get_children():
		if c is Level:
			p = c.scene_file_path
	currentSave.scene_path = p

func updateItemData() -> void:
	currentSave.items = PlayerManager.INVENTORY_DATA.getSaveData()

func updateQuestData() -> void:
	currentSave.quests = QuestManager.curret_quests 

func addPersistentValue(value : String) -> void:
	if checkPersistentValue(value) == false:
		currentSave.persistence.append(value)

func checkPersistentValue(value : String) -> bool:
	var p = currentSave.persistence as Array
	return p.has(value)

func removePersistentValue(value : String ) -> void:
	var p = currentSave.persistence as Array
	p.erase(value)
