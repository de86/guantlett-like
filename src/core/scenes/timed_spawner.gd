class_name TimedSpawner extends Node3D


signal spawned(spawned:Variant)


@export var _timed_spawner_def:TimedSpawnerDef

@export var _is_paused:bool = false
var _pool:Pool
var _timer:Timer
var _spawn_count:int


#region Public API
func spawn () -> Node3D:
	if _is_paused:
		return
	
	if _timed_spawner_def.spawn_limit > 0 and _spawn_count >= _timed_spawner_def.spawn_limit:
		return
	
	var instance = _pool.get_instance() as Node3D
	if !instance:
		return
	
	_spawn_count += 1
	instance.set_global_position(global_position)
	
	# Wait for physics server to sync new position before proceeding
	await get_tree().process_frame
	
	if instance.has_method("on_spawn"):
		instance.on_spawn()
	
	if instance.has_method("set_resource"):
		instance.set_resource(_timed_spawner_def.spawn_resource)
	
	spawned.emit(instance)
	
	return instance
#endregion


#region Lifecycle
func _ready ():
	_pool = PoolManager.get_pool(_timed_spawner_def.pool_def.pool_identifier)
	
	if _timed_spawner_def.spawn_automatically:
		_timer = Timer.new()
		add_child(_timer)
		_timer.timeout.connect(_on_spawn_interval_timeout)
		_timer.start(_timed_spawner_def.spawn_interval_seconds)
#endregion

#region Internal
func _on_spawn_interval_timeout ():
	spawn()
#endregion
