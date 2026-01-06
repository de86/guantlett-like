@tool
class_name PoolRegistry
extends Resource


@export var _pool_registry:Array[PoolDef]


func get_pools () -> Array[PoolDef]:
	return _pool_registry


func get_registered_pool_names () -> Array[StringName]:
	var pool_names:Array[StringName] = []
	for pool_def in _pool_registry:
		pool_names.push_back(pool_def.pool_identifier)
	
	return pool_names
