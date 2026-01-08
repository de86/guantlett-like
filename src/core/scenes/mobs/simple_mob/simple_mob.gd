class_name SimpleMob extends CharacterBody3D


signal mob_died(mob:SimpleMob)


@export var _simple_mob:SimpleMobDef
@export var _debug:bool = false

@onready var _health_pool:StatPool = %HealthPool
@onready var _debug_label_3D:Label3D = %Label3D
@onready var _visual_root:Node3D = %VisualRoot


var _follow_target:Node3D
var _pool:Pool
var _is_dead:bool = false


#region Public API
func on_collide_with_projectile (_projectile:Projectile) -> void:
	if _is_dead:
		return
	
	_health_pool.decrease()
	
	if _health_pool.is_empty():
		_die()


#region IPoolable
## Poolable Interface
func set_pool (pool:Pool) -> void:
	_pool = pool
#endregion


#region ISpawnable
func on_spawn () -> void:
	_is_dead = false
	
	Utils.enable_collision_layers(
		self,
		[
			Consts.COLLISION_LAYERS.Enemies
		],
		[
			Consts.COLLISION_LAYERS.Player,
			Consts.COLLISION_LAYERS.Enemies,
			Consts.COLLISION_LAYERS.Obstacles,
			Consts.COLLISION_LAYERS.PlayerProjectiles,
		]
	)
	
	if !_follow_target:
		_cache_player()
	
	process_mode = Node.PROCESS_MODE_INHERIT


func set_resource (simple_mob_resource:SimpleMobDef) -> void:
	_set_resource(simple_mob_resource)
#endregion
#endregion


#region Lifecycle
func _ready () -> void:
	_cache_player()
	_set_resource(_simple_mob)
	
	_debug_label_3D.visible = true if _debug else false


func _physics_process (_delta) -> void:
	if _is_dead:
		return
	
	_simple_mob.movement_behaviour.move(
		self,
		_delta,
		{"follow_target": _follow_target}
	)
#endregion

#region Internal
func _set_resource (simple_mob_resource:SimpleMobDef) -> void:
	if simple_mob_resource.identifier != _simple_mob.identifier:
		_simple_mob = simple_mob_resource
		_set_visual(_simple_mob.visual)
	
	_debug_label_3D.text = "%s %s" %[simple_mob_resource.identifier, name]
	
	# Maybe move this. Not really related to setting data
	_reset_health_pool()


func _set_visual (visual_packed_scene:PackedScene) -> void:
	if !visual_packed_scene:
		push_warning("Cannot update SimpleMob visual. No visual packed scene provided")
	
	var new_visual = visual_packed_scene.instantiate()
	Utils.queue_free_all_children_of_node(_visual_root)
	_visual_root.add_child(new_visual)


func _die () -> void:
	_is_dead = true
	mob_died.emit(self)
	
	_free_self()


func _free_self () -> void:
	if _pool:
		_pool.return_instance(self)
	else:
		queue_free()


func _reset_health_pool () -> void:
	_health_pool.set_max(_simple_mob.max_hp, {"fill": true})


func _cache_player () -> void:
	_follow_target = get_tree().get_first_node_in_group("player")
	if !_follow_target:
		push_warning("Unable to find player. Please ensure player node is in player global group")
#endregion
