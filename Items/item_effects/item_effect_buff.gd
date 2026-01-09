class_name ItemEffectBuff extends ItemEffect

@export_enum("MAX_HP", "ATTACK", "DEFENSE") var stat_name : String = "MAX_HP"
@export var amount : float = 5.0
@export var audio : AudioStream # Crunch sound

func use() -> void:
	# Add logic to Player Manager
	PlayerManager.add_run_buff(stat_name, amount)
	
	# Play Sound
	if audio:
		PauseMenu.playerAudio(audio)
