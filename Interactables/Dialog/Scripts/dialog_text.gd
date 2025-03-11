@tool
@icon( "res://GUI/dialog_system/icons/text_bubble.svg" )
class_name DialogText extends DialogItem

@export_multiline var text : String = "Placeholder text" : set = _set_text



func _set_text( value : String ) -> void:
	text = value
	if Engine.is_editor_hint():
		if example_dialog != null:
			_setEditorDisplay()


func _setEditorDisplay() -> void:
	example_dialog.setDialogText( self )
	example_dialog.content.visible_characters = -1
	pass
