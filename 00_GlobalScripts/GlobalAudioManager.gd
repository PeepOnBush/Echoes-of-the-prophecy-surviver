extends Node


var music_audio_player_count : int = 2
var currentMusicPlayer : int = 0
var musicPlayer : Array[AudioStreamPlayer] = []
var musicBus : String = "Music"
var musicFadeDuration : float = 2.5
var sfxBus : String = "SFX"

# Track tweens so we can kill them 
var player_tweens : Dictionary = {} 

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i  in music_audio_player_count:
		var audioPlayer = AudioStreamPlayer.new()
		add_child(audioPlayer)
		audioPlayer.bus = musicBus 
		musicPlayer.append(audioPlayer)
		audioPlayer.volume_db = -40
		player_tweens[audioPlayer] = null

func playMusic( _audio : AudioStream) -> void:
	if _audio == musicPlayer[currentMusicPlayer].stream:
		return
	currentMusicPlayer += 1
	if currentMusicPlayer > 1:
		currentMusicPlayer = 0
	
	var currentPlayer : AudioStreamPlayer = musicPlayer[currentMusicPlayer]
	currentPlayer.stream = _audio
	playAndFadeIn(currentPlayer)
	
	var oldAudioPlayer = musicPlayer[1]
	if currentMusicPlayer == 1:
		oldAudioPlayer = musicPlayer[0]
	fadeOutAndStop(oldAudioPlayer)
	pass
func play_sfx(_audio : AudioStream, _pitch_scale : float = 1.0) -> void:
	if _audio == null:
		return
	
	# 1. Create a temporary player
	var new_player = AudioStreamPlayer.new()
	add_child(new_player)
	
	# 2. Configure it
	new_player.stream = _audio
	new_player.bus = sfxBus
	new_player.pitch_scale = _pitch_scale
	
	# 3. Play
	new_player.play()
	
	# 4. Cleanup (Wait for finish, then delete self)
	await new_player.finished
	new_player.queue_free()

func playAndFadeIn(audioPlayer : AudioStreamPlayer) -> void:
	# 1. KILL EXISTING TWEEN on this player
	if player_tweens[audioPlayer] != null and player_tweens[audioPlayer].is_running():
		player_tweens[audioPlayer].kill()

	audioPlayer.play(0)
	var tween : Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	# 2. SAVE THE TWEEN
	player_tweens[audioPlayer] = tween
	
	tween.tween_property(audioPlayer, 'volume_db', 0, musicFadeDuration)

func fadeOutAndStop(audioPlayer : AudioStreamPlayer) -> void:
	# 1. KILL EXISTING TWEEN on this player (so it stops trying to fade IN)
	if player_tweens[audioPlayer] != null and player_tweens[audioPlayer].is_running():
		player_tweens[audioPlayer].kill()

	var tween : Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	# 2. SAVE THE TWEEN
	player_tweens[audioPlayer] = tween
	
	tween.tween_property(audioPlayer, 'volume_db', -40, musicFadeDuration)
	
	await tween.finished
	audioPlayer.stop()

func getCurrentTrack() -> AudioStream:
	return musicPlayer[currentMusicPlayer].stream
