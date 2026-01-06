@tool
class_name Spawner extends Node3D


@export var _spawn_automatically:bool = false
@export var _spawn_interval_seconds:float = 0.0


var _pool_name: StringName = &""
var _timer:Timer


func _ready ():
	if Engine.is_editor_hint():
		return
	
	if _spawn_automatically:
		_timer = Timer.new()
		add_child(_timer)
		_timer.timeout.connect(_on_spawn_interval_timeout)
		_timer.start(_spawn_interval_seconds)


func _on_spawn_interval_timeout ():
	spawn()


func _get_property_list () -> Array[Dictionary]:
	var pool_registry = load("res://src/game/data/res_pool_registry.tres") as PoolRegistry
	
	if not pool_registry:
		push_error("Failed to load pool_registry!")
		return []
	
	var names = pool_registry.get_registered_pool_names()
	print(names)
	
	return [{
		"name": "pool_name",
		"type": TYPE_STRING_NAME,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(names),
		"usage": PROPERTY_USAGE_DEFAULT
	}]


func _set(property: StringName, value: Variant) -> bool:
	if property == &"pool_name":
		_pool_name = value as StringName
		
		return true
	
	return false


func _get(property: StringName) -> Variant:
	if property == &"pool_name":
		return _pool_name
	
	return null


func spawn () -> Node:
	var pool = PoolManager.get_pool(_pool_name)
	var instance = pool.get_instance() as Node3D
	return instance
	
