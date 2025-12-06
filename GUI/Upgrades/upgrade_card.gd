class_name UpgradeCard extends Button

signal selected(upgrade : UpgradeData)

var upgrade_data : UpgradeData

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var icon_texture: TextureRect = $VBoxContainer/IconTexture
@onready var desc_label: Label = $VBoxContainer/DescLabel


func _ready() -> void:
	pressed.connect(on_pressed)

func set_card_data(_data : UpgradeData) -> void:
	upgrade_data = _data
	title_label.text = _data.title
	desc_label.text = _data.description
	if _data.icon:
		icon_texture.texture = _data.icon

func on_pressed() -> void:
	selected.emit(upgrade_data)
