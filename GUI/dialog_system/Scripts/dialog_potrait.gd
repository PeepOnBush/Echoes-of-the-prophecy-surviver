@tool
class_name DialogPotrait extends Sprite2D

# --- EMOTION FRAMES ---
# You can change these numbers to match your spritesheet
const FRAME_NEUTRAL = 0
const FRAME_LAUGH = 4
const FRAME_SCARED = 5
const FRAME_SAD = 6
const FRAME_CRY = 7
const FRAME_ANGRY = 8
const FRAME_SHOCKED = 9

# --- CONFIGURATION ---
var blink : bool = false : set = setBlink
var open_mouth : bool = false : set = setOpenMouth
var mouth_open_frames : int = 0
var audio_pitch_base : float = 1.0

# Store the current emotion for this sentence
var current_base_frame : int = 0

@onready var audio_stream_player: AudioStreamPlayer = $"../AudioStreamPlayer"

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	# Connect to letter added for mouth movement
	DialogSystem.letter_added.connect(checkMouthOpen)
	
	# NEW: We need to know when a new dialog starts to scan the text
	# Since DialogSystem emits 'started' when the box opens, 
	# we can also check whenever the text changes.
	# The easiest way is to hook into the letter_added and check if it's the START.
	
	blinker()

func checkMouthOpen( l : String) -> void:
	# --- NEW: EMOTION SCANNER ---
	# If we are at the very start of the text (visible characters is low), scan the whole string
	if DialogSystem.content.visible_characters <= 1:
		analyze_emotion(DialogSystem.plain_text)
	# ----------------------------

	if 'aeiouy1234567890'.contains(l.to_lower()):
		open_mouth = true
		mouth_open_frames += 3
		audio_stream_player.pitch_scale = randf_range(audio_pitch_base - 0.04 ,audio_pitch_base + 0.04 )
		audio_stream_player.play()
	elif '.,!?'.contains(l):
		audio_stream_player.pitch_scale = audio_pitch_base - 0.1
		audio_stream_player.play()
		mouth_open_frames = 0
	
	if mouth_open_frames > 0:
		mouth_open_frames -= 1
	
	if mouth_open_frames == 0:
		if open_mouth == true:
			open_mouth = false
			audio_stream_player.pitch_scale = randf_range(audio_pitch_base - 0.08 ,audio_pitch_base + 0.02 )
			audio_stream_player.play()

# --- NEW FUNCTION: SCANNER ---
func analyze_emotion(full_text : String) -> void:
	# Convert to uppercase so "haha" and "HAHA" both work
	var text = full_text.to_upper()
	
	# Default to Neutral
	current_base_frame = FRAME_NEUTRAL
	
	# 1. LAUGH
	if text.contains("HAHA") or text.contains("LOL") or text.contains("LMAO") or text.contains("HEHE"):
		current_base_frame = FRAME_LAUGH
		
	# 2. SCARED / NERVOUS
	elif text.contains("AAAA") or text.contains("RUN!") or text.contains("S-SORRY") or text.contains("..."):
		current_base_frame = FRAME_SCARED
		
	# 3. SAD
	elif text.contains("SIGH") or text.contains("DIED") or text.contains("LOST") or text.contains("SORRY"):
		current_base_frame = FRAME_SAD
		
	# 4. CRY
	elif text.contains("SOB") or text.contains("WAAAA") or text.contains("NOOO"):
		current_base_frame = FRAME_CRY
		
	# 5. ANGRY
	elif text.contains("DAMN") or text.contains("HATE") or text.contains("KILL") or text.contains("!!!"):
		current_base_frame = FRAME_ANGRY
		
	# 6. SHOCKED
	elif text.contains("WHAT?!") or text.contains("NANII") or text.contains("IMPOSSIBLE"):
		current_base_frame = FRAME_SHOCKED
		
	# Force an update immediately so the face changes before text starts typing
	updatePotrait()

func updatePotrait() -> void:
	var target_frame : int = 0
	
	# 1. Determine which frame we WANT to show
	if current_base_frame == FRAME_NEUTRAL:
		if open_mouth == true:
			target_frame = 2 # Mouth Open
		elif blink == true:
			target_frame = 1 # Blink
		else:
			target_frame = 0 # Neutral
	else:
		# If we found an emotion keyword (like "HAHA"), try to use that frame
		target_frame = current_base_frame

	# 2. SAFETY CHECK: Does this frame actually exist?
	# hframes * vframes = Total number of frames in the sprite sheet
	var total_frames_available = hframes * vframes
	
	if target_frame >= total_frames_available:
		# ERROR PREVENTION: 
		# We tried to show a frame (e.g. 9) that doesn't exist yet.
		# Fallback to Neutral (0) so the game doesn't crash.
		frame = 0
		return

	# 3. Apply the frame
	frame = target_frame

func setBlink(_value : bool) -> void:
	if blink != _value:
		blink = _value
		updatePotrait()

func blinker() -> void:
	if blink == false:
		await get_tree().create_timer(randf_range(0.1,3)).timeout
	else:
		await get_tree().create_timer(0.15).timeout
	blink = not blink
	blinker()

func setOpenMouth(_value : bool) -> void:
	if open_mouth != _value:
		open_mouth = _value
		updatePotrait()
