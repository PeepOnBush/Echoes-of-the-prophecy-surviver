class_name FootstepAudio2D extends AudioStreamPlayer2D

@export var footsteps_variants : Array[AudioStream]
var stream_randomizer : AudioStreamRandomizer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stream_randomizer = stream
	pass # Replace with function body.


func playFootstep() -> void:
	getFootstepType()
	play()
	pass

func getFootstepType() -> void:
	for t in get_tree().get_nodes_in_group("tilemaps"):
		if t is TileMapLayer:
			if t.tile_set.get_custom_data_layer_by_name("footstep_type") == -1 :
				continue
			var cell : Vector2i = t.local_to_map(t.to_local(global_position))
			var data : TileData = t.get_cell_tile_data(cell)
			if data:
				var type = data.get_custom_data("footstep_type")
				if type == null:
					continue
				stream_randomizer.set_stream(0,footsteps_variants[type])
			pass
	pass
