class_name State extends Node

## Store a reference to the player that this state belong to
static var player: Player
static var state_machine : playerStateMachine

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func init() -> void:
	pass

## What happen when the player enter this state ?
func Enter() -> void:
	
	pass
## What happen when the player exit this state ?
func Exit() -> void:
	
	pass 
## What happen when the _process update in this state ?
func Process(_delta : float) -> State:
	
	return null
	
func Physics(_delta : float) -> State:
	return null

func HandleInput( _event : InputEvent ) -> State:
	return null

