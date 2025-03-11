@tool
@icon("res://GUI/dialog_system/Icons/question_bubble.svg")

class_name DialogChoice extends DialogItem

var dialog_branches : Array[DialogBranch]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	for c in get_children():
		if c is DialogBranch:
			dialog_branches.append(c)


func _setEditorDisplay() -> void:
	setRelatedText()
	if dialog_branches.size() < 2:
		return
	example_dialog.setDialogChoice(self)
	pass

func setRelatedText() -> void:
	var _p = get_parent()
	var _t = _p.get_child(self.get_index() - 1)
	if _t is DialogText:
		example_dialog.setDialogText(_t)
		example_dialog.content.visible_characters = -1

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
