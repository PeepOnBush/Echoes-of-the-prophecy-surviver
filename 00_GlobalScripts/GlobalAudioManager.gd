extends Node


var music_audio_player_count : int = 2
var currentMusicPlayer : int = 0
var musicPlayer : Array[AudioStreamPlayer] = []
var musicBus : String = "Music"
var musicFadeDuration : float = 2.5
var sfxBus : String = "SFX"

# Track tweens so we can kill them 
var player_tweens : Dictionary = {} 
# --- NEW: Track long/looping SFX ---
var looping_sfx_players : Dictionary = {}
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

# --- NEW FUNCTIONS FOR PROLONGED SOUNDS ---

# We require a "key" (a string name) so we can look it up later to stop it.
func play_looping_sfx(_audio: AudioStream, key: String, _pitch_scale: float = 1.0) -> void:
	if _audio == null:
		return
		
	# 1. If a sound with this key is already playing, stop it first to prevent duplicates
	if looping_sfx_players.has(key):
		stop_looping_sfx(key)
		
	# 2. Create the player
	var new_player = AudioStreamPlayer.new()
	add_child(new_player)
	
	new_player.stream = _audio
	new_player.bus = sfxBus
	new_player.pitch_scale = _pitch_scale
	new_player.play()
	
	# 3. Store the player in the dictionary using the key
	looping_sfx_players[key] = new_player

func stop_looping_sfx(key: String) -> void:
	# 1. Check if we have a sound playing under this key
	if looping_sfx_players.has(key):
		var player = looping_sfx_players[key]
		
		# 2. Safely stop and delete it
		if is_instance_valid(player):
			player.stop()
			player.queue_free()
			
		# 3. Remove it from the dictionary
		looping_sfx_players.erase(key)

func getCurrentTrack() -> AudioStream:
	return musicPlayer[currentMusicPlayer].stream
