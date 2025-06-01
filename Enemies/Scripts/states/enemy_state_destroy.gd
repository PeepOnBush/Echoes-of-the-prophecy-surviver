class_name EnemyStateDestroy extends EnemyState

const PICKUP = preload("res://Items/item_pickup/ItemPickup.tscn")
@export var animName : String = "destroy"
@export var knockback_speed : float = 350.0
@export var decelerate_speed : float = 10.0

@export_category("AI")

@export_category("Item drops")
@export var drops : Array[DropData]



var _damage_position : Vector2
var _direction : Vector2


func init() -> void:
	enemy.enemyDestroyed.connect(_on_enemy_destroyed)
	pass

## What happen when the player enter this state ?
func Enter() -> void:
	disable_hurt_box()
	enemy.invulnerable = true
	_direction = enemy.global_position.direction_to(_damage_position)
	enemy.SetDirection(_direction)
	enemy.velocity = _direction * -knockback_speed
	enemy.UpdateAnimation( animName )
	enemy.animationPlayer.animation_finished.connect(_on_animation_finished)
	drop_items()
	PlayerManager.rewardXP(enemy.xp_reward)
	pass
## What happen when the player exit this state ?
func Exit() -> void:
	pass 
## What happen when the _process update in this state ?
func Process(_delta : float) -> EnemyState:
	enemy.velocity -=enemy.velocity * decelerate_speed * _delta
	return null
	
func Physics(_delta : float) -> EnemyState:
	return null

func _on_enemy_destroyed(hurt_box : HurtBox) -> void:
	_damage_position = hurt_box.global_position
	state_machine.changeState(self)
	
func _on_animation_finished( _a : String ) -> void:
	enemy.queue_free()



func disable_hurt_box() -> void:
	var hurt_box : HurtBox = enemy.get_node_or_null("HurtBox")
	if hurt_box:
		hurt_box.monitoring = false
		
func drop_items() -> void:
	if drops.size() == 0:
		return
	for i in drops.size():
		if drops[i] == null or drops[i].item == null:
			continue
		var drop_count : int = drops[i].getDropCount()
		for j in drop_count:
			var drop : ItemPickup = PICKUP.instantiate() as ItemPickup
			drop.item_data = drops[i].item
			enemy.get_parent().call_deferred("add_child", drop)
			drop.global_position = enemy.global_position
			drop.velocity = enemy.velocity.rotated(randf_range(-1.5, 1.5) * randf_range(0.9, 1.5) )
	pass
