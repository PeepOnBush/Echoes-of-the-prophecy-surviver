class_name NotificationUI extends Control

var notification_queue : Array

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var panel_container: PanelContainer = $PanelContainer
@onready var title_label: Label = $PanelContainer/VBoxContainer/Label
@onready var message_label: Label = $PanelContainer/VBoxContainer/Label2



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	panel_container.visible = false
	animation_player.animation_finished.connect(notificationAnimationFinished)
	pass # Replace with function body.


func addNotificationToQueue(_title : String, _message : String) -> void:
	notification_queue.append(
		{
			title = _title,
			message = _message
		}
	)
	if animation_player.is_playing():
		return
	displayNotification()
	pass


func displayNotification() -> void:
	var _n = notification_queue.pop_front()
	if _n == null:
		return
	title_label.text = _n.title
	message_label.text = _n.message
	animation_player.play("show_notification")
	pass

func notificationAnimationFinished(_a : String) -> void:
	displayNotification()
	pass
