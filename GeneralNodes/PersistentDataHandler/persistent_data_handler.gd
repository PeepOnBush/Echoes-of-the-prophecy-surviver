class_name PersistentDataHandler extends Node

signal dataLoaded
var value : bool = false

func _ready() -> void:
	getValue()
	print(_getName())
	pass

func setValue() -> void:
	SaveManager.addPersistentValue(_getName())
	pass

func getValue() -> void:
	value = SaveManager.checkPersistentValue(_getName())
	dataLoaded.emit()
	pass

func _getName() -> String:
	# res://Levels//AreaO1/01.tscn/treasurechest/PersistentDataHandler
	return get_tree().current_scene.scene_file_path + "/" + get_parent().name + "/" + name 

func removeValue() -> void:
	SaveManager.removePersistentValue(_getName())
	pass
