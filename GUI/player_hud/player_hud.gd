extends CanvasLayer

var hearts : Array[HeartGui] = []

func _ready():
	for child in $Control/HFlowContainer.get_children():
		if child is HeartGui:
			hearts.append(child)
			child.visible = false
	pass

func updateHp(_hp : int, _maxHP : int) -> void:
	updateMaxHp(_maxHP)
	for i in _maxHP :
		updateHeart(i,_hp)
	pass

func updateHeart(_index : int , _hp : int ) -> void:
	var _value : int = clampi(_hp - _index  * 2, 0 , 2)
	hearts[_index].value = _value
	pass
	
func updateMaxHp(_maxHP : int) -> void:
	var _heartCount : int  = roundi(_maxHP * 0.5)
	for i in hearts.size():
		if i < _heartCount:
			hearts[i].visible = true
		else :
			hearts[i].visible = false
	pass
