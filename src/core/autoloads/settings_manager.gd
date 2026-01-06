extends Node


# Add game config (AudioManager config etc.) management 

const SETTINGS_PATH:String = "user://game_settings.tres"

var settings:GameSettingsDef


func _ready():
	_load_settings()


## Loads and applies game settings. Will load default settings if no saved settings found
## Returns: void
func _load_settings () -> void:
	if ResourceLoader.exists(SETTINGS_PATH):
		settings = ResourceLoader.load(SETTINGS_PATH)
	
	if !settings:
		settings = GameSettingsDef.new()
	
	settings.apply()


## Saves current settings to disk
## Returns: void
func _save_settings () -> void:
	var result = ResourceSaver.save(settings, SETTINGS_PATH)
	if result != OK:
		push_error("Failed to save settings: %s" %result)


## Sets the master volume
## Returns: void
## Params:
##  value: int - New master volume value between 1 and 10
func set_master_volume (value:int) -> void:
	settings.master_volume = _normalize_volume_value(value)
	_save_and_apply_settings()


## Sets the music volume
## Returns: void
## Params:
##  value: int - New music volume value between 1 and 10
func set_music_volume (value:int) -> void:
	settings.music_volume = _normalize_volume_value(value)
	_save_and_apply_settings()


## Sets the sfx volume
## Returns: void
## Params:
##  value: int - New sfx volume value between 1 and 10
func set_sfx_volume (value:int) -> void:
	settings.sfx_volume = _normalize_volume_value(value)
	_save_and_apply_settings()


## Normalises an int value between 0 and 10 to a float value suitable for setting audio bus volume
## Values < 0 will result in value of 0 and values > 10 will result in value of 10
## Returns: float
## Params:
##  value:int
func _normalize_volume_value(value:int) -> float:
	return clampi(value, 0, 10) / 10.0


func _save_and_apply_settings () -> void:
	settings.apply()
	_save_settings()
