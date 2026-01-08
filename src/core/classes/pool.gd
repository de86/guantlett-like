class_name Pool extends Node3D
## A generic object pooling system for efficient reuse of frequently created/destroyed objects.
##
## The Pool manages a collection of pre-instantiated nodes that can be retrieved and returned
## to avoid the performance cost of frequent instantiation and destruction. Pooled objects
## are positioned at a holding location when inactive and can optionally have their processing
## disabled to reduce overhead.


## Defines which active object to recycle when the pool reaches maximum capacity.
enum RecycleStrategy {
	OLDEST,  ## Recycle the first object that was spawned (FIFO)
	NEWEST   ## Recycle the most recently spawned object (LIFO)
}


#region Configuration
## Unique identifier for this pool instance.
var pool_identifier: StringName

## The scene to instantiate for each pooled object.
var _poolable_scene: PackedScene

## Initial number of objects to create when populating the pool.
var _pool_size: int = 10

## Maximum number of objects that can exist (active + inactive).
var _max_pool_size: int = 20

## If true, recycles active objects when pool reaches max capacity.
## WARNING: This will forcibly return active objects to the pool, which may cause unexpected behavior.
var _can_recycle_active_objects: bool = false

## If true, automatically populates the pool with _pool_size instances on _ready().
var _auto_populate_pool: bool = true

## If true, sets inactive objects to PROCESS_MODE_DISABLED to reduce overhead.
var _disable_processing_when_inactive: bool = true

## Strategy to use when recycling active objects (only used if _can_recycle_active_objects is true).
var _recycle_strategy: RecycleStrategy = RecycleStrategy.OLDEST
#endregion


#region State
## Objects currently available for use (in the pool).
var _available_pool_items: Array[Node]

## Objects currently in use (spawned in the game world).
var _active_pool_items: Array[Node]

## Default parent node for retrieved objects if none is specified.
var _default_parent_node_when_active: Node3D

## Counter for generating unique instance names.
var _instance_count: int = 0

## World position where inactive pool objects are stored.
const _pool_position = Vector3(0, -10, 0)
#endregion


#region Public API
## Initializes the pool with configuration from a PoolDef resource.
##
## @param pool_def: Configuration resource containing pool settings.
func init(pool_def: PoolDef) -> void:
	pool_identifier = pool_def.pool_identifier
	_poolable_scene = pool_def.poolable_scene
	_pool_size = pool_def.pool_size
	_max_pool_size = pool_def.max_pool_size
	_auto_populate_pool = pool_def.auto_populate_pool
	_can_recycle_active_objects = pool_def.can_recycle_active_objects
	_disable_processing_when_inactive = pool_def.disable_processing_when_inactive
	_recycle_strategy = pool_def.recycle_strategy


## Retrieves an available object from the pool.
##
## The object is moved to the specified parent node (or default parent if none provided),
## made visible, and added to the active objects list. If the pool is empty, behavior depends
## on configuration:
## - If under max_pool_size: creates a new instance
## - If at max_pool_size and can_recycle_active_objects: recycles an active object
## - Otherwise: returns null
##
## @param parent: Optional parent node to reparent the object to. Uses default parent if null.
## @return: The retrieved pool object, or null if unavailable.
func get_instance(parent: Node = null) -> Node:
	return _retrieve_from_pool(parent)


## Returns an active object back to the pool for reuse.
##
## The object is disabled (collision off, invisible, processing disabled), moved to the pool
## position, and reparented to the pool node. It becomes available for future get_instance() calls.
##
## @param instance: The object to return to the pool.
func return_instance(instance: Node) -> void:
	_return_to_pool(instance)


## Sets the default parent node for objects retrieved without specifying a parent.
##
## @param node: The node to use as the default parent for retrieved objects.
func set_default_parent(node: Node) -> void:
	if !node:
		push_warning("Unable to set default parent node of pool %s. node parameter not provided" % pool_identifier)
		return
	
	_default_parent_node_when_active = node
#endregion


#region Lifecycle
## Initializes the pool position and optionally pre-populates the pool.
func _ready() -> void:
	set_global_position(_pool_position)
	
	if _auto_populate_pool:
		_populate_pool()
#endregion


#region Internal
## Creates and initializes instances to reach the configured pool size.
##
## Only creates the number of instances needed to reach _pool_size, so calling this
## multiple times won't create duplicates.
func _populate_pool() -> void:
	var num_items_to_instance = _pool_size - _available_pool_items.size()
	if !num_items_to_instance:
		return
	
	for i in range(num_items_to_instance):
		var instance = _create_instance()
		_return_to_pool(instance)


## Returns an object to the pool, making it available for reuse.
##
## Disables collision, hides the object, moves it to pool position, reparents it to the pool,
## and optionally disables processing to reduce overhead.
##
## @param instance: The object to return to the pool.
func _return_to_pool(instance: Node) -> void:
	if _active_pool_items.has(instance):
		_active_pool_items.erase(instance)
	
	Utils.disable_all_collision(instance)
	instance.visible = false
	
	if instance.has_method("set_global_position"):
		instance.set_global_position(global_position)
	instance.reparent(self)
	
	# Wait for global position to sync with physics server before disabling
	# Ensures that pool item has been moved to the pools position first
	await get_tree().process_frame
	
	if _disable_processing_when_inactive:
		instance.process_mode = Node.PROCESS_MODE_DISABLED
	
	_available_pool_items.append(instance)


## Creates a new pool object instance from the configured scene.
##
## Instantiates the poolable scene, assigns it a unique name, configures it as invisible,
## calls set_pool() if available, and adds it as a child of the pool node.
##
## @return: The newly created instance, or null if instantiation fails.
func _create_instance() -> Node:
	if !_poolable_scene:
		push_error("Pool %s: poolable_scene is null" % pool_identifier)
		return null
	
	var instance = _poolable_scene.instantiate()
	if !instance:
		push_error("Pool %s: failed to instantiate scene" % pool_identifier)
		return null
	
	if !instance.has_method("set_pool"):
		push_warning("Pool %s: instance does not implement set_pool() method" % pool_identifier)
	
	instance.name = "%s %s" % [pool_identifier, _instance_count]
	_instance_count += 1
	instance.visible = false
	
	if instance.has_method("set_pool"):
		instance.set_pool(self)
	
	add_child(instance)
	return instance


## Retrieves an object from the available pool or creates/recycles one if needed.
##
## Handles three scenarios:
## 1. Available pool has objects: returns one immediately
## 2. Pool under max size: creates a new instance
## 3. Pool at max size with recycling enabled: recycles an active object per _recycle_strategy
## 4. Pool at max size without recycling: returns null
##
## @param parent: Optional parent node to reparent the object to.
## @return: The retrieved pool object, or null if unavailable.
func _retrieve_from_pool(parent: Node = null) -> Node:
	var current_total_pool_size: int = _get_current_total_pool_size()
	if _available_pool_items.size() <= 0 and current_total_pool_size >= _max_pool_size and !_can_recycle_active_objects:
		push_warning("Pool %s at maximum size" % pool_identifier)
		
		return null
	
	if _available_pool_items.size() <= 0:
		if current_total_pool_size >= _pool_size and current_total_pool_size < _max_pool_size:
			_available_pool_items.append(_create_instance())
		elif current_total_pool_size >= _max_pool_size:
			var recycled_instance = _active_pool_items.pop_front() if _recycle_strategy == RecycleStrategy.OLDEST else _active_pool_items.pop_back()
			_return_to_pool(recycled_instance)
	
	var instance = _available_pool_items.pop_front()
	var parent_node: Node = parent if parent else _default_parent_node_when_active
	instance.reparent(parent_node)
	instance.visible = true
	_active_pool_items.append(instance)
	
	return instance


## Calculates the total number of pooled objects (active + available).
##
## @return: The total pool size.
func _get_current_total_pool_size() -> int:
	return _active_pool_items.size() + _available_pool_items.size()
#endregion
