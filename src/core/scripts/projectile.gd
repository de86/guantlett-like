class_name Projectile
extends Node3D


@onready var _visual_root:Node3D = %VisualRoot
@onready var _area_3D:Area3D = %Area3D
@onready var _collision_shape:CollisionShape3D = %CollisionShape3D
@onready var _lifetime_timer:Timer = %LifetimeTimer

var _type:StringName
var _speed:float
var _pool:Pool
var _has_hit:bool = false

#region Public API
func init (projectile_def:ProjectileDef):
	_has_hit = false
	_speed = projectile_def.speed
	_collision_shape.shape = projectile_def.collision_shape
	
	if projectile_def.type == _type:
		var visual_instance = projectile_def.visual.instantiate()
		Utils.queue_free_all_children_of_node(_visual_root)
		_visual_root.add_child(visual_instance)
	
	_lifetime_timer.start(projectile_def.lifetime_in_seconds)
#endregion

#region IPoolable
## Poolable Interface
func set_pool (pool:Pool):
	_pool = pool
#endregion

#region ISpawnable
func on_spawn ():
	_collision_shape.set_deferred("disabled", false)
	Utils.enable_collision_layers(
		_area_3D,
		[Consts.COLLISION_LAYERS.PlayerProjectiles],
		[Consts.COLLISION_LAYERS.Enemies, Consts.COLLISION_LAYERS.Obstacles]
	)
	set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
#endregion

#region Lifecycle
func _ready ():
	_area_3D.body_entered.connect(_on_body_collision)
	_lifetime_timer.timeout.connect(_on_lifetime_end)


func _physics_process(delta):
	var velocity = -global_transform.basis.z * _speed
	if velocity.length_squared() > 0.001:
		global_position += velocity * delta
		look_at(global_position + velocity)
#endregion

#region Internal
func _on_lifetime_end ():
	_die()
	_free_self()


func _die ():
	_lifetime_timer.stop()


func _on_body_collision (body:Node3D):
	if _has_hit:
		return
	
	_has_hit = true
	
	if body.has_method("on_collide_with_projectile"):
		body.on_collide_with_projectile(self)
	
	_free_self()


func _free_self ():
	global_position = Vector3(9999, 9999, 9999) # Immediately move mob to avoid collisions
	Utils.disable_all_collision(self)
	_collision_shape.set_deferred("disabled", true)
	
	if _pool:
		_pool.return_instance(self)
	else:
		queue_free()
#endregion
