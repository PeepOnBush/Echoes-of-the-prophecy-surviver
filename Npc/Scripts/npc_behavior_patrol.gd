@tool
extends NPCBehavior

const COLORS = [Color(1,0,0) , Color(1,1,0), Color(1,1,1), Color(0,1,0), Color(0,1,1), Color(0,0,1), Color(1,0,1)]

@export var walk_speed : float = 30.0

var patrol_location : Array[PatrolLocation]
var current_location_index : int = 0
var target : PatrolLocation
var has_started : bool = false 
var last_phase : String = ""
var direction : Vector2

@onready var timer: Timer = $Timer


func _ready() -> void:
	gatherPatrolLocation()
	if Engine.is_editor_hint():
		child_entered_tree.connect(gatherPatrolLocation)
		child_order_changed.connect(gatherPatrolLocation)
		return
	super()
	if patrol_location.size() == 0:
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	target = patrol_location[0]

func _process(_delta : float) -> void:
	if Engine.is_editor_hint():
		return
	if npc.global_position.distance_to(target.target_position) < 1:
		idlePhase()

func start() -> void:
	if npc.doBehavior == false or patrol_location.size() < 2:
		return
	if has_started == true:
		if timer.time_left == 0:
			walkPhase()
		return #idle phase is still waiting for the timer timeout
	 
	has_started = true
	idlePhase()
	pass
func idlePhase() -> void:
	#IDLE PHASE
	npc.global_position = target.target_position
	npc.state = "idle"
	npc.velocity = Vector2.ZERO
	npc.updateAnimation()
	
	var wait_time : float = target.wait_time
	current_location_index += 1
	if current_location_index >= patrol_location.size():
		current_location_index = 0
	
	target = patrol_location[current_location_index]
	
	if wait_time > 0:
		timer.start(wait_time)
		await timer.timeout
	
	if npc.doBehavior == false:
		return
	
	walkPhase()
	pass

func walkPhase() -> void:
	npc.state = "walk"
	direction = global_position.direction_to(target.target_position)
	npc.direction = direction
	npc.velocity = walk_speed * direction
	npc.updateDirection(target.target_position)
	npc.updateAnimation()
	pass


func gatherPatrolLocation( _n : Node = null) -> void:
	patrol_location = []
	for c in get_children():
		if c is PatrolLocation:
			patrol_location.append(c)
	if Engine.is_editor_hint():
		if patrol_location.size() > 0:
			for i in patrol_location.size():
				var _p = patrol_location[i] as PatrolLocation
				
				if not _p.transform_changed.is_connected(gatherPatrolLocation):
					_p.transform_changed.connect(gatherPatrolLocation)
				
				_p.updateLabel(str(i))
				_p.modulate = getColorByIndex(i)
				
				var _next : PatrolLocation
				if i < patrol_location.size() - 1:
					_next = patrol_location[i+1]
				else:
					_next = patrol_location[0]
				_p.updateLine(_next.position)
	pass

func getColorByIndex( i : int) -> Color:
	var color_count : int = COLORS.size()
	while i > color_count - 1:
		i -= color_count
	return COLORS[i]
