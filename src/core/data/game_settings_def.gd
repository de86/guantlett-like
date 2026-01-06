class_name GameSettingsDef
extends Resource


# Master Volume value between 0 and 1
@export var master_volume:float = 1.0

# Music Volume value between 0 and 1
@export var music_volume:float = 1.0

# SFX Volume value between 0 and 1
@export var sfx_volume:float = 1.0


## Applies all settings - consider splitting up into audio, graphics etc or apply individual settings
## Returns: void
func apply () -> void:
	# Audio
	_update_audio_bus_volume("Master", master_volume)
	_update_audio_bus_volume("Music", music_volume)
	_update_audio_bus_volume("SFX", sfx_volume)


# Can probably be moved into an proper audio manager later
func _update_audio_bus_volume (bus_name:String, volume:float) -> void:
	var busIndex = AudioServer.get_bus_index(bus_name)
	if busIndex == -1:
		push_warning("Audio bus %s not found." % bus_name)
		return
	
	AudioServer.set_bus_volume_db(busIndex, linear_to_db(volume))
