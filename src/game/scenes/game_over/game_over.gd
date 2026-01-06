extends Node2D


var _sfx_success:SoundDef = preload("res://src/game/data/sound/sfx_success.tres")


func _enter_tree():
	AudioManager.register_sound_def(_sfx_success)


func _ready () -> void:
	AudioManager.play_sfx(_sfx_success.name)


func _input (event:InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_SPACE:
		SceneManager.switch_scene(Consts.SCENE_NAME.GAME)
