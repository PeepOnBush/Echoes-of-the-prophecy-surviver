class_name  Quest extends Resource

@export var title : String 
@export var steps : Array[String]
@export var reward_xp : int
@export var reward_items : Array[QuestRewardItem] = []


@export_multiline var description : String 




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
