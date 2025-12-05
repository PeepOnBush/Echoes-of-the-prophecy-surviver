extends Node


var music_audio_player_count : int = 2
var currentMusicPlayer : int = 0
var musicPlayer : Array[AudioStreamPlayer] = []
var musicBus : String = "Music"
var musicFadeDuration : float = 2.5

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i  in music_audio_player_count:
		var audioPlayer = AudioStreamPlayer.new()
		add_child(audioPlayer)
		audioPlayer.bus = musicBus 
		musicPlayer.append(audioPlayer)
		audioPlayer.volume_db = -40

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

func playAndFadeIn( audioPlayer : AudioStreamPlayer) -> void:
	audioPlayer.play(0)
	var tween : Tween = create_tween()
	tween.tween_property(audioPlayer, 'volume_db',0,musicFadeDuration)
	pass

func fadeOutAndStop( audioPlayer : AudioStreamPlayer) -> void:
	var tween : Tween = create_tween()
	tween.tween_property(audioPlayer,'volume_db',-40, musicFadeDuration)
	await tween.finished
	audioPlayer.stop()
	pass

func getCurrentTrack() -> AudioStream:
	return musicPlayer[currentMusicPlayer].stream
