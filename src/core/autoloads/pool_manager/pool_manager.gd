extends Node

@export var _pool_registry:PoolRegistry

@onready var _pool_root:Node = %PoolRoot

var _pool_map:Dictionary[StringName, Pool]
var _active_pools_node:Node3D


func _ready ():
	var pool_defs = _pool_registry.get_pools()
	for pool_def in pool_defs:
		var pool = Pool.new()
		pool.init(pool_def)
		pool.name = pool_def.pool_identifier
		_pool_root.add_child(pool)
		_pool_map.set(pool_def.pool_identifier, pool)


func get_pool (pool_name:StringName) -> Pool:
	return _pool_map.get(pool_name)


func get_all_pool_names () -> Array[StringName]:
	return _pool_map.keys()


func register_active_pools_node (node: Node3D):
	_active_pools_node = node
	
	for pool in _pool_map.values() as Array[Pool]:
		var active_pool_node = Node3D.new()
		active_pool_node.name = pool.pool_identifier
		_active_pools_node.add_child(active_pool_node)
		pool.set_default_parent(active_pool_node)
