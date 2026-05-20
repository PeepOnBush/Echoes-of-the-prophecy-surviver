class_name ItemDescriptionPanel extends PanelContainer

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var desc_label: RichTextLabel = $VBoxContainer/DescLabel

func _ready() -> void:
	clear_info()

func update_info(item: ItemData) -> void:
	if item:
		name_label.text = item.name
		desc_label.text = item.description
	else:
		clear_info()

func clear_info() -> void:
	name_label.text = ""
	desc_label.text = ""
