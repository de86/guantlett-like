extends CanvasLayer


@onready var _start_button:Button = %StartButton
@onready var _settings_button:Button = %SettingsButton
@onready var _quit_button:Button = %QuitButton


func _ready ():
	_start_button.pressed.connect(_on_start_button_pressed)
	_settings_button.pressed.connect(_on_options_button_pressed)
	_quit_button.pressed.connect(_on_quit_button_pressed)


func _on_start_button_pressed ():
	SceneManager.switch_scene(Consts.SCENE_NAME.GAME)


func _on_options_button_pressed ():
	print("Options")


func _on_quit_button_pressed ():
	get_tree().quit()
