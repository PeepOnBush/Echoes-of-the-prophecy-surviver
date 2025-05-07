class_name Stats extends PanelContainer

@onready var label_level: Label = %Level
@onready var label_xp: Label = %XP
@onready var label_attack: Label = %Attack
@onready var label_defense: Label = %Defense
@onready var attack_change: Label = %Attack_change
@onready var defense_change: Label = %Defense_change


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PauseMenu.shown.connect(updateStats)
	pass # Replace with function body.

func updateStats() -> void:
	var _p : Player = PlayerManager.player
	label_level.text = str(_p.level)
	
	if _p.level < PlayerManager.level_requirements.size():
		label_xp.text = str(_p.xp) + "/" + str(PlayerManager.level_requirements[_p.level])
	else:
		label_xp.text = "max level"
	label_attack.text = str(_p.attack)
	label_defense.text = str(_p.defense)
	pass
