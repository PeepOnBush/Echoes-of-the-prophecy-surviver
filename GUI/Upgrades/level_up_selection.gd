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
	var controller = PlayerManager.player.get_node("OrbitController")
	match upgrade.buff:
		UpgradeData.UpgradeType.HEAL:
			player.update_hp(int(upgrade.value))
			pass
		UpgradeData.UpgradeType.ATTACK:
			player.attack += int(upgrade.value)
			pass
		UpgradeData.UpgradeType.ORCISH_VITALITY:
			var bonus = int(upgrade.value)
			player.max_hp += bonus
			player.hp += bonus # Heal the amount we gained so the bar fills
			player.update_hp(0) # Force UI refresh
			print("Max HP Increased to: ", PlayerManager.player.max_hp)
			pass
		UpgradeData.UpgradeType.KNOCKBACK_FORCE: # Add enum
			PlayerManager.player.knockback_multiplier += upgrade.value # e.g. 0.2
			pass
		UpgradeData.UpgradeType.DEFENSE:
			player.defense += int(upgrade.value)
			pass
		UpgradeData.UpgradeType.SPEED:
			# You assume you have a move_speed variable on player state
			pass 
		UpgradeData.UpgradeType.ARROW:
			player.arrow_count += int(upgrade.value)
			pass
		UpgradeData.UpgradeType.ATTACK_SPEED:
			# Reduce delay by 15% (Multiply by 0.85)
			var weapon = player.find_child("WeaponPivot") # The floating bow
			if weapon:
				weapon.fire_rate *= (1.0 - upgrade.value) # e.g. 0.2 * 0.85 = 0.17
			pass
		UpgradeData.UpgradeType.CRIT_CHANCE:
			PlayerManager.player.crit_chance += upgrade.value
			print("Crit Chance is now: ", PlayerManager.player.crit_chance)
			pass
		UpgradeData.UpgradeType.CRIT_DAMAGE:
			player.crit_multiplier += upgrade.value # e.g. +1.0
			pass
		UpgradeData.UpgradeType.BOMB:
			player.bomb_count += int(upgrade.value)
			pass
		UpgradeData.UpgradeType.ORBIT:
			player.enableOrbitDarkGemController()
			pass
		UpgradeData.UpgradeType.ORBIT_SPEED:
			controller.upgrade_speed(upgrade.value)
			pass
		UpgradeData.UpgradeType.ORBIT_RANGE:
			controller.upgrade_radius(upgrade.value) # e.g. +15.0
			pass
		UpgradeData.UpgradeType.ORBIT_SIZE:
			controller.upgrade_size(upgrade.value) # e.g. +0.2
			pass
		UpgradeData.UpgradeType.RAGE:
			player.attack += int(upgrade.value)
			player.stamina += int(upgrade.value)
			print(player.attack + " attack " + player.stamina + " stamina")
			pass
		UpgradeData.UpgradeType.RICOCHET:
			player.arrow_ricochet_amount += int(upgrade.value)
			pass
		UpgradeData.UpgradeType.ELEMENT_FIRE:
			player.chance_to_burn += upgrade.value
			pass
		UpgradeData.UpgradeType.ELEMENT_ICE:
			player.chance_to_freeze += upgrade.value
		UpgradeData.UpgradeType.BERSERK:
			player.berserker_mode = true
			player.updateDamageValue() # Recalculate immediately
			pass
		UpgradeData.UpgradeType.INVINCIBILITY_UP: # Add enum
			player.invincibility_duration += upgrade.value # +0.5
			pass
		UpgradeData.UpgradeType.EXPLOSIVE_ARROW:
			player.explosive_arrows_unlocked = true
			pass
	# Close Menu
	visible = false
	get_tree().paused = false
	upgrade_selected.emit()
	pass
