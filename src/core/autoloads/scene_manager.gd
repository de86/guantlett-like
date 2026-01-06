extends Node


var _scene_root_node:Node


# All scenes that we expect the this scene manager to handle should have their paths
# defined here
# Consider replacing with scene resources
# Consider a separate scene_registry resource to avoid paths breaking
var _scene_path_registry:Dictionary[Consts.SCENE_NAME, String] = {
	Consts.SCENE_NAME.SPLASH: "res://src/core/scenes/splash/splash.tscn",
	Consts.SCENE_NAME.MAIN_MENU: "res://src/game/scenes/ui/main_menu/main_menu.tscn",
	Consts.SCENE_NAME.GAME: "res://src/game/scenes/game/game.tscn",
	Consts.SCENE_NAME.WIN: "res://src/game/scenes/win/win.tscn",
	Consts.SCENE_NAME.GAME_OVER: "res://src/game/scenes/game_over/game_over.tscn",
}

# Cache of loaded scenes
var _loaded_scene_registry:Dictionary[Consts.SCENE_NAME, PackedScene] = {}


## Sets the node that any instantiated scene will live in
## [i]Returns[/i]: void
## [b]Paramaters[/b]:
## - [b]scene_root_node[/b]: Node - The node that new scene will be created under
func set_scene_root_node (scene_root_node:Node) -> void:
	_scene_root_node = scene_root_node


## Switch to the given scene. Can return null if required parameters are missing
## [i]Returns[/i]: Node
## [b]Parameters[/b]:
## - [b]scene_name[/b]: Consts.SCENE_NAME - The scene to switch to
## - [b]options[/b]: Dictionary with Consts.SCENE_NAME keys:
##   - [code]&"should_free_target_node_children"[/code]: bool - queue_free all children of target before adding the new scene. Defaults to true.
##   - [code]&"should_defer_adding_scene"[/code]: bool - Defers add_child call to end of frame if true. Defaults to false.
func switch_scene (
	scene_name:Consts.SCENE_NAME,
	options:Dictionary[StringName, Variant] = {}
) -> Node:
	if !_scene_root_node:
		push_error("scene_manager.switch_scene: Cannot switch scene. Scene root node is not set.")
		return null
	
	if scene_name == null:
		push_error("scene_manager.switch_scene: scene parameter is null")
		return null
	
	var scene:PackedScene = _loaded_scene_registry.get(scene_name)
	if !scene:
		var scene_path:String = _scene_path_registry.get(scene_name)
		if !scene_path:
			push_error("scene_manager.switch_scene: Scene %s not found in scene registry" %scene_name)
			return null
		
		scene = ResourceLoader.load(scene_path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE)
		if !scene:
			push_error("scene_manager.switch_scene: PackedScene not found at path %s" %scene_path)
			return null
	
	_loaded_scene_registry.set(scene_name, scene)
	
	# Parse Options
	# ToDo: Genericize options parsing
	# ToDo: Consider "One shot scene" option that flags the scene to be removed from registry once scene is changed e.g. Splash Scene
	const K_QUEUE_FREE_CHILDREN:StringName = &"should_free_target_node_children"
	const K_DEFER_ADD:StringName = &"should_defer_adding_scene"
	const OPTIONS_DEFAULTS:Dictionary[StringName, Variant] = {
		K_QUEUE_FREE_CHILDREN: true,
		K_DEFER_ADD:false,
	}
	var _options:Dictionary[StringName, Variant] = Utils.merge_options(options, OPTIONS_DEFAULTS)
	
	if _options.get(K_QUEUE_FREE_CHILDREN, false):
		Utils.queue_free_all_children_of_node(_scene_root_node)
	
	var instantiated_scene = scene.instantiate()
	if _options.get(K_DEFER_ADD, false):
		_scene_root_node.call_deferred("add_child", instantiated_scene)
	else:
		_scene_root_node.add_child(instantiated_scene)
	
	EventBus.scene_changed.emit(scene_name, instantiated_scene)
	
	return instantiated_scene


## Removes the scene with the given scene_name from the scene_cache if present.
## [i]Returns[/i]: Bool - True if removal was successful, False if removal failed
## [b]Parameters:[/b]
##  - [b]scene_name[/b]: Consts.SCENE_NAME
func remove_from_cache (scene_name:Consts.SCENE_NAME) -> bool:
	if scene_name == null:
		push_error("scene_manager.remove_from_cache: Scene parameter is null")
		return false
	
	return _loaded_scene_registry.erase(scene_name)
