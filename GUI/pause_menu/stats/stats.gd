class_name Stats extends PanelContainer

var inventory : InventoryData

@onready var label_level: Label = %Level
@onready var label_xp: Label = %XP
@onready var label_attack: Label = %Attack
@onready var label_defense: Label = %Defense
@onready var attack_change: Label = %Attack_change
@onready var defense_change: Label = %Defense_change


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PauseMenu.shown.connect(updateStats)
	PauseMenu.preview_stats_change.connect(onPreviewStatsChanged)
	inventory = PlayerManager.INVENTORY_DATA
	inventory.equipment_changed.connect(updateStats)
	pass # Replace with function body.

func updateStats() -> void:
	var _p : Player = PlayerManager.player
	label_level.text = str(_p.level)
	
	if _p.level < PlayerManager.level_requirements.size():
		label_xp.text = str(_p.xp) + "/" + str(PlayerManager.level_requirements[_p.level])
	else:
		label_xp.text = "max level"
	label_attack.text = str(_p.attack + inventory.getAttackBonus())
	label_defense.text = str(_p.defense+ inventory.getDefendBonus())
	pass

func onPreviewStatsChanged(_item : ItemData) -> void:
	attack_change.text = ""
	defense_change.text = ""
	if not _item is EquipableItemData:
		return
	
	var equipment : EquipableItemData = _item
	var attack_delta : int = inventory.getAttackBonusDiff(equipment)
	var defense_delta : int = inventory.getDefenseBonusDiff(equipment)
	
	updateChangedLabel(attack_change,attack_delta)
	updateChangedLabel(defense_change,defense_delta)
	
	
	pass


func updateChangedLabel(label : Label, value : int ) -> void:
	if value > 0:
		label.text = "+" + str(value)
		label.modulate = Color.LIGHT_GREEN
	elif value < 0 :
		label.text = str(value)
		label.modulate = Color.INDIAN_RED
	pass
