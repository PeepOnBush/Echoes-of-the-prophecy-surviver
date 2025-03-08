@tool
@icon("res://GUI/dialog_system/Icons/answer_bubble.svg")
class_name DialogBranch extends DialogItem

@export var text : String = "ok...."

var dialog_items : Array[DialogItem]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	for c in get_children():
		if c is DialogItem:
			dialog_items.append(c)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
