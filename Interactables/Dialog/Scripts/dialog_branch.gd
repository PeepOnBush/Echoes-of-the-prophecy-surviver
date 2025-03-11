@tool
@icon("res://GUI/dialog_system/Icons/answer_bubble.svg")
class_name DialogBranch extends DialogItem

@export var text : String = "ok...." : set = setText

var dialog_items : Array[DialogItem]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return
	
	for c in get_children():
		if c is DialogItem:
			dialog_items.append(c)

func _setEditorDisplay() -> void:
	var _p = get_parent()
	if _p is DialogChoice:
		setRelatedText()
		if _p.dialog_branches.size() < 2:
			return
		example_dialog.setDialogChoice(_p as DialogChoice)
		pass
	pass

func setRelatedText() -> void:
	var _p = get_parent()
	var _p2 = _p.get_parent()
	var _t = _p2.get_child(_p.get_index() - 1)
	if _t is DialogText:
		example_dialog.setDialogText(_t)
		example_dialog.content.visible_characters = -1

func setText( value : String ) -> void:
	text = value
	if Engine.is_editor_hint():
		if example_dialog != null:
			_setEditorDisplay()
