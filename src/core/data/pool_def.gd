@tool
class_name PoolDef
extends Resource

@export var pool_identifier:StringName
@export var poolable_scene:PackedScene
@export var pool_size:int = 10
@export var max_pool_size:int = 20
@export var can_recycle_active_objects:bool = false
@export var auto_populate_pool:bool = true
@export var disable_processing_when_inactive:bool = true
@export var immediately_disable_processing:bool = true
@export var recycle_strategy:Pool.RecycleStrategy = Pool.RecycleStrategy.OLDEST
