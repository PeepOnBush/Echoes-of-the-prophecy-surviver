class_name Stats extends PanelContainer

@onready var label_level: Label = $VBoxContainer/HBoxContainer/Level
@onready var label_xp: Label = $VBoxContainer/HBoxContainer2/XP
@onready var label_attack: Label = $VBoxContainer/HBoxContainer3/Attack
@onready var label_defense: Label = $VBoxContainer/HBoxContainer4/Defense


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PauseMenu.shown.connect(updateStats)
	pass # Replace with function body.

func updateStats() -> void:
	var _p : Player = PlayerManager.player
	label_level.text = str(_p.level)
	label_xp.text = str(_p.xp) + "/" + str(PlayerManager.level_requirements[_p.level])
	label_attack.text = str(_p.attack)
	label_defense.text = str(_p.defense)
	pass
