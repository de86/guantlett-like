class_name AudioSet extends Resource
## A flexible collection of named audio entries

@export var sounds: Array[AudioEntry] = []

var _sound_cache: Dictionary = {}


## Play a sound by name at a 3D position
##
## @param sound_name: The key of the sound to play
## @param position: World position to play the sound
## @return: The AudioStreamPlayer3D used, or null if sound not found
func play_3d(sound_name: String, position: Vector3) -> AudioStreamPlayer3D:
	_ensure_cache()
	
	if not _sound_cache.has(sound_name):
		push_warning("AudioSet: Sound '%s' not found" % sound_name)
		return null
	
	var entry: AudioEntry = _sound_cache[sound_name]
	var stream = entry.get_stream()
	
	if not stream:
		push_warning("AudioSet: Sound '%s' has no stream" % sound_name)
		return null
	
	return AudioManager.play_sfx_3d(
		stream,
		position,
		entry.volume_db,
		entry.pitch_range.x,
		entry.pitch_range.y,
		entry.max_distance
	)


## Play a sound by name in 2D
##
## @param sound_name: The key of the sound to play
## @return: The AudioStreamPlayer used, or null if sound not found
func play_2d(sound_name: String) -> AudioStreamPlayer:
	_ensure_cache()
	
	if not _sound_cache.has(sound_name):
		push_warning("AudioSet: Sound '%s' not found" % sound_name)
		return null
	
	var entry: AudioEntry = _sound_cache[sound_name]
	var stream = entry.get_stream()
	
	if not stream:
		push_warning("AudioSet: Sound '%s' has no stream" % sound_name)
		return null
	
	return AudioManager.play_sfx(
		stream,
		entry.volume_db,
		entry.pitch_range.x,
		entry.pitch_range.y
	)


## Play a sound attached to a node
##
## @param sound_name: The key of the sound to play
## @param parent: Node to attach the sound to
## @return: The AudioStreamPlayer3D used, or null if sound not found
func play_attached(sound_name: String, parent: Node3D) -> AudioStreamPlayer3D:
	_ensure_cache()
	
	if not _sound_cache.has(sound_name):
		push_warning("AudioSet: Sound '%s' not found" % sound_name)
		return null
	
	var entry: AudioEntry = _sound_cache[sound_name]
	var stream = entry.get_stream()
	
	if not stream:
		push_warning("AudioSet: Sound '%s' has no stream" % sound_name)
		return null
	
	return AudioManager.play_sfx_3d_attached(
		stream,
		parent,
		entry.volume_db,
		entry.pitch_range.x,
		entry.pitch_range.y
	)


## Check if a sound exists
func has_sound(sound_name: String) -> bool:
	_ensure_cache()
	return _sound_cache.has(sound_name)


## Get all available sound names
func get_sound_names() -> Array[String]:
	_ensure_cache()
	var names: Array[String] = []
	names.assign(_sound_cache.keys())
	return names


func _ensure_cache() -> void:
	if _sound_cache.is_empty() and not sounds.is_empty():
		_build_cache()


func _build_cache() -> void:
	_sound_cache.clear()
	for entry in sounds:
		if entry and entry.key:
			_sound_cache[entry.key] = entry
