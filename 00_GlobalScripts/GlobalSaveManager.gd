extends Node

const SAVE_PATH = "user://"

signal game_loaded
signal game_saved


var currentSave : Dictionary = {
	scene_path = "",
	player =  {
		level = 1,
		xp = 1,
		attack = 1, 
		defense = 1,
		hp = 1,
		max_hp = 1,
		pos_x = 0,
		pos_y = 0,
		arrow_count = 0,
		bomb_count = 0
	},
	items = [],
	persistence = [],
	quests = [
		#return { title = "not found", is_complete = false, completed_steps = [''] }
	],
	abilities = ["", "", "", ""]
}

func saveGame() -> void:
	updatePlayerData()
	updateScenePath()
	updateItemData()
	updateQuestData()
	var file := FileAccess.open( SAVE_PATH + "save.sav",FileAccess.WRITE)
	var save_json = JSON.stringify(currentSave)
	file.store_line( save_json )
	game_saved.emit()

	pass

func getSaveFile() -> FileAccess:
	return FileAccess.open( SAVE_PATH + "save.sav",FileAccess.READ )



func loadGame() -> void:
	var file := getSaveFile()
	var load_json = JSON.new()
	load_json.parse(file.get_line())
	var save_dict : Dictionary = load_json.get_data() as Dictionary
	currentSave = save_dict
	
	LevelManager.load_new_level(currentSave.scene_path,"",Vector2.ZERO)
	
	await LevelManager.level_load_started
	
	PlayerManager.set_player_position( Vector2(currentSave.player.pos_x, currentSave.player.pos_y))
	PlayerManager.set_health( currentSave.player.hp, currentSave.player.max_hp)
	var _p : Player = PlayerManager.player
	_p.level = currentSave.player.level
	_p.xp = currentSave.player.xp
	_p.attack = currentSave.player.attack
	_p.defense = currentSave.player.defense
	_p.arrow_count = currentSave.player.arrow_count
	_p.bomb_count = currentSave.player.bomb_count
	PlayerManager.INVENTORY_DATA.parseSaveData(currentSave.items)
	QuestManager.curret_quests = currentSave.quests
	await LevelManager.level_loaded
	game_loaded.emit()
	pass

func updatePlayerData() -> void:
	var p : Player = PlayerManager.player
	currentSave.player.hp = p.hp
	currentSave.player.max_hp = p.max_hp
	currentSave.player.pos_x = p.global_position.x
	currentSave.player.pos_y = p.global_position.y
	currentSave.player.level = p.level
	currentSave.player.xp = p.xp
	currentSave.player.attack = p.attack
	currentSave.player.defense = p.defense
	currentSave.player.arrow_count = p.arrow_count
	currentSave.player.bomb_count = p.bomb_count
	currentSave.abilities = p.player_abilities.abilities
	pass

func updateScenePath() -> void:
	var p : String = ""
	for c in get_tree().root.get_children():
		if c is Level:
			p = c.scene_file_path
	currentSave.scene_path = p
	pass


func updateItemData() -> void:
	currentSave.items = PlayerManager.INVENTORY_DATA.getSaveData()
	pass

func updateQuestData() -> void:
	currentSave.quests = QuestManager.curret_quests 
	pass

func addPersistentValue( value : String) -> void:
	if checkPersistentValue(value) == false:
		currentSave.persistence.append(value)
	pass

func checkPersistentValue(value : String) -> bool:
	var p = currentSave.persistence as Array
	return p.has(value)

func removePersistentValue(value : String ) -> void:
	var p = currentSave.persistence as Array
	p.erase(value)
	pass
