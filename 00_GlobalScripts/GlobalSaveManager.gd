extends Node

const SAVE_PATH = "user://"

signal game_loaded
signal game_saved


var currentSave : Dictionary = {
	scene_path = "",
	player =  {
		hp = 1,
		max_hp = 1,
		pos_x = 0,
		pos_y = 0
	},
	items = [],
	persistence = [],
	quests = [],
	
}

func saveGame() -> void:
	updatePlayerData()
	updateScenePath()
	updateItemData()
	var file := FileAccess.open( SAVE_PATH + "save.sav",FileAccess.WRITE)
	var save_json = JSON.stringify(currentSave)
	file.store_line( save_json )
	game_saved.emit()

	pass

func loadGame() -> void:
	var file := FileAccess.open( SAVE_PATH + "save.sav",FileAccess.READ )
	var load_json = JSON.new()
	load_json.parse(file.get_line())
	var save_dict : Dictionary = load_json.get_data() as Dictionary
	currentSave = save_dict
	
	LevelManager.load_new_level(currentSave.scene_path,"",Vector2.ZERO)
	
	await LevelManager.level_load_started
	
	PlayerManager.set_player_position( Vector2(currentSave.player.pos_x, currentSave.player.pos_y))
	PlayerManager.set_health( currentSave.player.hp, currentSave.player.max_hp)
	PlayerManager.INVENTORY_DATA.parseSaveData(currentSave.items)
	await LevelManager.level_loaded
	game_loaded.emit()
	pass

func updatePlayerData() -> void:
	var p : Player = PlayerManager.player
	currentSave.player.hp = p.hp
	currentSave.player.max_hp = p.max_hp
	currentSave.player.pos_x = p.global_position.x
	currentSave.player.pos_y = p.global_position.y

func updateScenePath() -> void:
	var p : String = ""
	for c in get_tree().root.get_children():
		if c is Level:
			p = c.scene_file_path
	currentSave.scene_path = p
	
func updateItemData() -> void:
	currentSave.items = PlayerManager.INVENTORY_DATA.getSaveData()

func addPersistentValue( value : String) -> void:
	if checkPersistentValue(value) == false:
		currentSave.persistence.append(value)
	pass

func checkPersistentValue(value : String) -> bool:
	var p = currentSave.persistence as Array
	return p.has(value)
