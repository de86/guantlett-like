extends Node


func _ready ():
	SceneManager.switch_scene(Consts.SCENE_NAME.SPLASH, {&"should_remove_scene_from_registry": Consts.SCENE_NAME})
	await EventBus.splash_complete
	SceneManager.remove_from_cache(Consts.SCENE_NAME.SPLASH) 
	
	SceneManager.switch_scene(Consts.SCENE_NAME.MAIN_MENU)
