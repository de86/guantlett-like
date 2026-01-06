extends Node3D


@onready var _pools_node:Node3D = %Pools


func _init ():
	EventBus.player_exited_floor.connect(_on_player_exited)
	EventBus.player_died.connect(_on_player_died)


func _ready():
	PoolManager.register_active_pools_node(_pools_node)


func _on_player_died ():
	SceneManager.switch_scene(Consts.SCENE_NAME.GAME_OVER)


func _on_player_exited ():
	SceneManager.switch_scene(Consts.SCENE_NAME.WIN)
