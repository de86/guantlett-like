# AutoLoad: AudioManager
extends Node
## Manages all audio in the game including music, SFX, and UI sounds.
##
## Provides methods for playing sounds with pooling, volume control, and persistence.
## Supports both 2D and 3D spatial audio.


## Emitted when master volume changes
signal master_volume_changed(volume: float)
## Emitted when music volume changes
signal music_volume_changed(volume: float)
## Emitted when SFX volume changes
signal sfx_volume_changed(volume: float)
## Emitted when UI volume changes
signal ui_volume_changed(volume: float)


#region Audio Buses
const BUS_MASTER = "Master"
const BUS_MUSIC = "Music"
const BUS_SFX = "SFX"
const BUS_UI = "UI"
#endregion


#region Configuration
## Number of AudioStreamPlayer nodes to pool for 2D sounds
@export var sfx_pool_size: int = 20
## Number of AudioStreamPlayer3D nodes to pool for 3D sounds
@export var sfx_3d_pool_size: int = 10
## Default music fade duration in seconds
@export var music_fade_duration: float = 1.0
#endregion


#region State
var _current_music: AudioStreamPlayer
var _next_music: AudioStreamPlayer
var _is_music_transitioning: bool = false

var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_3d_pool: Array[AudioStreamPlayer3D] = []

var _master_volume: float = 1.0
var _music_volume: float = 0.8
var _sfx_volume: float = 1.0
var _ui_volume: float = 1.0
#endregion


#region Lifecycle
func _ready() -> void:
	_setup_audio_buses()
	_create_music_players()
	_populate_sfx_pools()
	_load_volume_settings()


func _setup_audio_buses() -> void:
	# Create buses if they don't exist
	_ensure_bus_exists(BUS_MUSIC, BUS_MASTER)
	_ensure_bus_exists(BUS_SFX, BUS_MASTER)
	_ensure_bus_exists(BUS_UI, BUS_MASTER)


func _ensure_bus_exists(bus_name: String, parent_bus: String = BUS_MASTER) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	
	if bus_index == -1:
		# Bus doesn't exist, create it
		var parent_index = AudioServer.get_bus_index(parent_bus)
		AudioServer.add_bus()
		var new_bus_index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(new_bus_index, bus_name)
		AudioServer.set_bus_send(new_bus_index, parent_bus)
		
		print("AudioManager: Created audio bus '%s' with parent '%s'" % [bus_name, parent_bus])


func _create_music_players() -> void:
	_current_music = AudioStreamPlayer.new()
	_current_music.bus = BUS_MUSIC
	_current_music.name = "CurrentMusic"
	add_child(_current_music)
	
	_next_music = AudioStreamPlayer.new()
	_next_music.bus = BUS_MUSIC
	_next_music.name = "NextMusic"
	add_child(_next_music)


func _populate_sfx_pools() -> void:
	# 2D SFX Pool
	for i in sfx_pool_size:
		var player = AudioStreamPlayer.new()
		player.bus = BUS_SFX
		player.name = "SFXPlayer_%d" % i
		add_child(player)
		_sfx_pool.append(player)
	
	# 3D SFX Pool
	for i in sfx_3d_pool_size:
		var player = AudioStreamPlayer3D.new()
		player.bus = BUS_SFX
		player.name = "SFXPlayer3D_%d" % i
		add_child(player)
		_sfx_3d_pool.append(player)
#endregion


#region Music Control
## Plays a music track with optional crossfade
##
## @param stream: The AudioStream to play
## @param fade_in: Whether to fade in the music
## @param fade_duration: Duration of fade in seconds (uses default if not specified)
func play_music(stream: AudioStream, fade_in: bool = true, fade_duration: float = -1.0) -> void:
	if fade_duration < 0:
		fade_duration = music_fade_duration
	
	if not stream:
		push_warning("AudioManager: Attempted to play null music stream")
		return
	
	# If same music is already playing, do nothing
	if _current_music.stream == stream and _current_music.playing:
		return
	
	if fade_in and _current_music.playing:
		await _crossfade_music(stream, fade_duration)
	else:
		_current_music.stream = stream
		_current_music.play()
		if fade_in:
			_fade_in(_current_music, fade_duration)


## Stops the currently playing music
##
## @param fade_out: Whether to fade out before stopping
## @param fade_duration: Duration of fade in seconds
func stop_music(fade_out: bool = true, fade_duration: float = -1.0) -> void:
	if fade_duration < 0:
		fade_duration = music_fade_duration
	
	if fade_out:
		await _fade_out(_current_music, fade_duration)
	
	_current_music.stop()


## Pauses the current music
func pause_music() -> void:
	_current_music.stream_paused = true


## Resumes paused music
func resume_music() -> void:
	_current_music.stream_paused = false


## Returns whether music is currently playing
func is_music_playing() -> bool:
	return _current_music.playing


func _crossfade_music(new_stream: AudioStream, duration: float) -> void:
	if _is_music_transitioning:
		return
	
	_is_music_transitioning = true
	
	# Swap players
	var temp = _current_music
	_current_music = _next_music
	_next_music = temp
	
	# Start new music
	_current_music.stream = new_stream
	_current_music.volume_db = -80
	_current_music.play()
	
	# Crossfade
	var tween = create_tween().set_parallel(true)
	tween.tween_property(_current_music, "volume_db", 0, duration)
	tween.tween_property(_next_music, "volume_db", -80, duration)
	
	await tween.finished
	
	_next_music.stop()
	_is_music_transitioning = false
#endregion


#region SFX Control (2D)
## Plays a 2D sound effect with optional pitch randomization
##
## @param stream: The AudioStream to play
## @param volume_db: Volume in decibels (0 = normal, negative = quieter, positive = louder)
## @param pitch_min: Minimum pitch scale (1.0 = normal, only used if different from pitch_max)
## @param pitch_max: Maximum pitch scale (1.0 = normal, only used if different from pitch_min)
## @return: The AudioStreamPlayer used, or null if none available
func play_sfx(
	stream: AudioStream, 
	volume_db: float = 0.0,
	pitch_min: float = 1.0,
	pitch_max: float = 1.0
) -> AudioStreamPlayer:
	if not stream:
		push_warning("AudioManager: Attempted to play null SFX stream")
		return null
	
	var player = _get_available_sfx_player()
	
	if not player:
		push_warning("AudioManager: No available SFX players in pool")
		return null
	
	# Calculate pitch (randomize if min != max)
	var pitch = pitch_min if pitch_min == pitch_max else randf_range(pitch_min, pitch_max)
	
	player.stream = stream
	player.pitch_scale = pitch
	player.volume_db = volume_db
	player.play()
	
	return player


## Plays a UI sound with optional pitch randomization (uses SFX pool but on UI bus)
##
## @param stream: The AudioStream to play
## @param volume_db: Volume in decibels (0 = normal)
## @param pitch_min: Minimum pitch scale (1.0 = normal)
## @param pitch_max: Maximum pitch scale (1.0 = normal)
func play_ui_sound(
	stream: AudioStream,
	volume_db: float = 0.0,
	pitch_min: float = 1.0,
	pitch_max: float = 1.0
) -> AudioStreamPlayer:
	if not stream:
		push_warning("AudioManager: Attempted to play null UI stream")
		return null
	
	var player = _get_available_sfx_player()
	
	if not player:
		push_warning("AudioManager: No available SFX players for UI sound")
		return null
	
	# Calculate pitch (randomize if min != max)
	var pitch = pitch_min if pitch_min == pitch_max else randf_range(pitch_min, pitch_max)
	
	# Temporarily switch to UI bus
	var original_bus = player.bus
	player.bus = BUS_UI
	player.stream = stream
	player.pitch_scale = pitch
	player.volume_db = volume_db
	player.play()
	
	# Restore original bus when done
	player.finished.connect(func(): player.bus = original_bus, CONNECT_ONE_SHOT)
	
	return player


func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_pool:
		if not player.playing:
			return player
	
	return null
#endregion


#region SFX Control (3D Spatial)
## Plays a 3D spatial sound effect at a position with optional pitch randomization
##
## @param stream: The AudioStream to play
## @param position: World position to play the sound
## @param volume_db: Volume in decibels (0 = normal, negative = quieter, positive = louder)
## @param pitch_min: Minimum pitch scale (1.0 = normal)
## @param pitch_max: Maximum pitch scale (1.0 = normal)
## @param max_distance: Maximum distance sound can be heard
## @return: The AudioStreamPlayer3D used, or null if none available
func play_sfx_3d(
	stream: AudioStream, 
	position: Vector3, 
	volume_db: float = 0.0,
	pitch_min: float = 1.0,
	pitch_max: float = 1.0,
	max_distance: float = 50.0
) -> AudioStreamPlayer3D:
	if not stream:
		push_warning("AudioManager: Attempted to play null 3D SFX stream")
		return null
	
	var player = _get_available_sfx_3d_player()
	
	if not player:
		push_warning("AudioManager: No available 3D SFX players in pool")
		return null
	
	# Calculate pitch (randomize if min != max)
	var pitch = pitch_min if pitch_min == pitch_max else randf_range(pitch_min, pitch_max)
	
	player.stream = stream
	player.global_position = position
	player.pitch_scale = pitch
	player.volume_db = volume_db
	player.max_distance = max_distance
	player.play()
	
	return player


## Plays a 3D sound attached to a node (follows the node) with optional pitch randomization
##
## @param stream: The AudioStream to play
## @param parent: Node to attach the sound to
## @param volume_db: Volume in decibels (0 = normal)
## @param pitch_min: Minimum pitch scale (1.0 = normal)
## @param pitch_max: Maximum pitch scale (1.0 = normal)
## @return: The AudioStreamPlayer3D used, or null if none available
func play_sfx_3d_attached(
	stream: AudioStream,
	parent: Node3D,
	volume_db: float = 0.0,
	pitch_min: float = 1.0,
	pitch_max: float = 1.0
) -> AudioStreamPlayer3D:
	if not stream:
		push_warning("AudioManager: Attempted to play null 3D SFX stream")
		return null
	
	if not is_instance_valid(parent):
		push_warning("AudioManager: Invalid parent node for 3D SFX")
		return null
	
	var player = _get_available_sfx_3d_player()
	
	if not player:
		push_warning("AudioManager: No available 3D SFX players in pool")
		return null
	
	# Calculate pitch (randomize if min != max)
	var pitch = pitch_min if pitch_min == pitch_max else randf_range(pitch_min, pitch_max)
	
	# Reparent to the target node
	player.reparent(parent)
	player.position = Vector3.ZERO  # Play at parent's position
	
	player.stream = stream
	player.pitch_scale = pitch
	player.volume_db = volume_db
	player.play()
	
	# Return to AudioManager when done
	player.finished.connect(func(): _return_3d_player_to_pool(player), CONNECT_ONE_SHOT)
	
	return player


func _get_available_sfx_3d_player() -> AudioStreamPlayer3D:
	for player in _sfx_3d_pool:
		if not player.playing:
			return player
	
	return null


func _return_3d_player_to_pool(player: AudioStreamPlayer3D) -> void:
	if player.get_parent() != self:
		player.reparent(self)
	player.position = Vector3.ZERO
#endregion


#region Volume Control
## Sets master volume
##
## @param volume: Volume from 0.0 (muted) to 1.0 (full)
func set_master_volume(volume: float) -> void:
	_master_volume = clamp(volume, 0.0, 1.0)
	_set_bus_volume(BUS_MASTER, _master_volume)
	master_volume_changed.emit(_master_volume)
	_save_volume_settings()


## Sets music volume
##
## @param volume: Volume from 0.0 (muted) to 1.0 (full)
func set_music_volume(volume: float) -> void:
	_music_volume = clamp(volume, 0.0, 1.0)
	_set_bus_volume(BUS_MUSIC, _music_volume)
	music_volume_changed.emit(_music_volume)
	_save_volume_settings()


## Sets SFX volume
##
## @param volume: Volume from 0.0 (muted) to 1.0 (full)
func set_sfx_volume(volume: float) -> void:
	_sfx_volume = clamp(volume, 0.0, 1.0)
	_set_bus_volume(BUS_SFX, _sfx_volume)
	sfx_volume_changed.emit(_sfx_volume)
	_save_volume_settings()


## Sets UI volume
##
## @param volume: Volume from 0.0 (muted) to 1.0 (full)
func set_ui_volume(volume: float) -> void:
	_ui_volume = clamp(volume, 0.0, 1.0)
	_set_bus_volume(BUS_UI, _ui_volume)
	ui_volume_changed.emit(_ui_volume)
	_save_volume_settings()


## Gets master volume
func get_master_volume() -> float:
	return _master_volume


## Gets music volume
func get_music_volume() -> float:
	return _music_volume


## Gets SFX volume
func get_sfx_volume() -> float:
	return _sfx_volume


## Gets UI volume
func get_ui_volume() -> float:
	return _ui_volume


func _set_bus_volume(bus_name: String, volume: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_warning("AudioManager: Bus '%s' not found" % bus_name)
		return
	
	# Convert linear volume to decibels
	# Volume of 0.0 = -80db (effectively muted)
	# Volume of 1.0 = 0db (full volume)
	var db = linear_to_db(volume) if volume > 0 else -80
	AudioServer.set_bus_volume_db(bus_index, db)
#endregion


#region Fade Helpers
func _fade_in(player: AudioStreamPlayer, duration: float) -> void:
	player.volume_db = -80
	var tween = create_tween()
	tween.tween_property(player, "volume_db", 0, duration)
	await tween.finished


func _fade_out(player: AudioStreamPlayer, duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(player, "volume_db", -80, duration)
	await tween.finished
#endregion


#region Persistence
func _save_volume_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", _master_volume)
	config.set_value("audio", "music_volume", _music_volume)
	config.set_value("audio", "sfx_volume", _sfx_volume)
	config.set_value("audio", "ui_volume", _ui_volume)
	config.save("user://audio_settings.cfg")


func _load_volume_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://audio_settings.cfg")
	
	if err != OK:
		# First time, use defaults
		_save_volume_settings()
		return
	
	_master_volume = config.get_value("audio", "master_volume", 1.0)
	_music_volume = config.get_value("audio", "music_volume", 0.8)
	_sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
	_ui_volume = config.get_value("audio", "ui_volume", 1.0)
	
	# Apply loaded volumes
	_set_bus_volume(BUS_MASTER, _master_volume)
	_set_bus_volume(BUS_MUSIC, _music_volume)
	_set_bus_volume(BUS_SFX, _sfx_volume)
	_set_bus_volume(BUS_UI, _ui_volume)
#endregion
