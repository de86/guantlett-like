class_name TimedSpawner extends Node3D


signal spawned(spawned:Variant)


@export var _spawn_automatically:bool = false
@export var _spawn_interval_seconds:float = 0.0
@export var _spawn_location:Vector3
@export var _pool_def:PoolDef
# ToDo: Need to make this more generic
@export var _simple_mob_resource:SimpleMobDef


var _pool:Pool
var _timer:Timer


#region Public API
func spawn () -> Node3D:
	var instance = _pool.get_instance() as Node3D
	if !instance:
		return
	
	var spawn_location = _spawn_location if _spawn_location else global_position
	instance.set_global_position(spawn_location)
	
	if instance.has_method("on_spawn"):
		instance.on_spawn()
	
	if instance.has_method("set_resource"):
		instance.set_resource(_simple_mob_resource)
	
	spawned.emit(instance)
	
	return instance
#endregion


#region Lifecycle
func _ready ():
	_pool = PoolManager.get_pool(_pool_def.pool_identifier)
	
	if _spawn_automatically:
		_timer = Timer.new()
		add_child(_timer)
		_timer.timeout.connect(_on_spawn_interval_timeout)
		_timer.start(_spawn_interval_seconds)
#endregion

#region Internal
func _on_spawn_interval_timeout ():
	spawn()
#endregion
