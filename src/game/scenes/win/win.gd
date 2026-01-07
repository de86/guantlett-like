extends Node2D


func _ready () -> void:
	pass


func _input (event:InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_SPACE:
		SceneManager.switch_scene(Consts.SCENE_NAME.GAME)
