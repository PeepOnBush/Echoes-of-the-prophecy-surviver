class_name Experience extends ItemEffect

@export var xp_reward : int = 1
@export var audio : AudioStream
func use() -> void:
	PlayerManager.rewardXP(xp_reward)
	PauseMenu.playerAudio(audio)
