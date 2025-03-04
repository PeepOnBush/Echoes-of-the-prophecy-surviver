@tool
@icon("res://GUI/dialog_system/Icons/chat_bubble.svg")
class_name DialogItem extends Node

@export var npc_info : NPCResource 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	checkNpcData()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func checkNpcData() -> void:
	if npc_info == null:
		var p = self
		var _checking : bool = true
		while _checking == true:
			p = p.get_parent()
			if p:
				if p is NPC and p.npc_resource:
					npc_info = p.npc_resource
					_checking = false
			else:
				_checking = false
