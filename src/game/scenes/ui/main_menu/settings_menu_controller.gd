extends CenterContainer


@onready var _music_volume_slider:Slider = %MusicVolumeSlider
@onready var _sfx_volume_slider:Slider = %SFXVolumeSlider


func _ready ():
	_music_volume_slider.drag_ended.connect(_on_music_volume_changed)
	_sfx_volume_slider.drag_ended.connect(_on_sfx_volume_changed)


func _on_music_volume_changed (changed:bool):
	if changed:
		SettingsManager.set_music_volume(int(_music_volume_slider.value))


func _on_sfx_volume_changed (changed:bool):
	if changed:
		SettingsManager.set_sfx_volume(int(_sfx_volume_slider.value))
