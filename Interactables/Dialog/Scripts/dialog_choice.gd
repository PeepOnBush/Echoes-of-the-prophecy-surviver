@tool
@icon("res://GUI/dialog_system/Icons/question_bubble.svg")

class_name DialogChoice extends DialogItem

var dialog_branches : Array[DialogBranch]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
func _get_configuration_warnings() -> PackedStringArray:
	if checkForDialogBranches() == false:
		return ["Requires atleast 2 DialogBranches nodes."]
	else:
		return []

func checkForDialogBranches() -> bool:
	var _count : int = 0
	for c in get_children():
		if c is DialogBranch:
			_count += 1
			if _count > 1:
				return true
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
