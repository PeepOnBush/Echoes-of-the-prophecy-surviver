class_name LevelUpSelection extends CanvasLayer

signal upgrade_selected

const CARD_SCENE = preload("res://GUI/Upgrades/UpgradeCard.tscn") # Adjust path to where you saved Step 2
#@export var all_upgrades : Array[UpgradeData] # Drag your 3 test resources here!

@onready var card_container: HBoxContainer = $HBoxContainer

func _ready() -> void:
	visible = false
	# Listen for the player manager signal
	PlayerManager.leveled_up.connect(show_options)

func show_options() -> void:
	get_tree().paused = true
	visible = true
	
	for c in card_container.get_children():
		c.queue_free()
	
	var options : Array[UpgradeData] = []
	
	# --- NEW: GET POOL FROM MANAGER ---
	# This pulls (Defaults + What you bought from NPCs)
	var available_pool = PlayerManager.get_battle_upgrade_pool()
	# ----------------------------------
	
	# Safety check
	if available_pool.size() < 3:
		print("Not enough upgrades in pool!")
		options = available_pool # Just show what we have
	else:
		# Pick 3 Random
		for i in range(3):
			if available_pool.size() > 0:
				var picked = available_pool.pick_random()
				options.append(picked)
				available_pool.erase(picked)
	
	# 4. Create Card Instances
	for option in options:
		var card_instance = CARD_SCENE.instantiate()
		card_container.add_child(card_instance)
		card_instance.set_card_data(option)
		card_instance.selected.connect(apply_upgrade)
	pass

func apply_upgrade(upgrade : UpgradeData) -> void:
	var player = PlayerManager.player
	
	match upgrade.buff:
		UpgradeData.UpgradeType.HEAL:
			player.update_hp(int(upgrade.value))
		UpgradeData.UpgradeType.ATTACK:
			player.attack += int(upgrade.value)
		UpgradeData.UpgradeType.DEFENSE:
			player.defense += int(upgrade.value)
		UpgradeData.UpgradeType.SPEED:
			# You assume you have a move_speed variable on player state
			pass 
		UpgradeData.UpgradeType.ARROW:
			player.arrow_count += int(upgrade.value)
		UpgradeData.UpgradeType.BOMB:
			player.bomb_count += int(upgrade.value)
		UpgradeData.UpgradeType.ORBIT:
			player.enableOrbitDarkGemController()
		UpgradeData.UpgradeType.RAGE:
			player.attack += int(upgrade.value)
			player.stamina += int(upgrade.value)
			print(player.attack + " attack " + player.stamina + " stamina")
			pass
	
	# Close Menu
	visible = false
	get_tree().paused = false
	upgrade_selected.emit()
	pass
