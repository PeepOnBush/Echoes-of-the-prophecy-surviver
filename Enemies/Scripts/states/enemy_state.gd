class_name EnemyState extends Node

## Stores  a reference to the enemy that this state belongs to 
var enemy : Enemy 
var state_machine : EnemyStateMachine


func init() -> void:
	pass

## What happen when the player enter this state ?
func Enter() -> void:
	
	pass
## What happen when the player exit this state ?
func Exit() -> void:
	
	pass 
## What happen when the _process update in this state ?
func Process(_delta : float) -> EnemyState:
	
	return null
	
func Physics(_delta : float) -> EnemyState:
	return null

