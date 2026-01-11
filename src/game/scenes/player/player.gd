class_name Player extends CharacterBody3D

#region Export Vars
@export var _max_hp:int = 5
@export var _move_speed:float = 2.0
@export var _input_deadzone:float = 0.01
@export var _aim_deadzone:float = 0.2
@export var _equipped_spell_def:ProjectileDef
@export var _damage_cooldown_in_seconds:int = 1
@export var _audio_set:AudioSet
@export var _dive_speed_curve:Curve
@export var _dive_duration:float = 1.0
@export var _dive_distance:float = 1.0
#endregion

#region Export Debug Vars
@export var _debug_god_mode:bool = false
#endregion

#region Onready Vars
@onready var _hurtbox:Area3D = %Hurtbox
@onready var _projectile_spawner:Spawner = %ProjectileSpawner
@onready var _projectile_spawn_point:Node3D = %ProjectileSpawnPoint
@onready var _camera:Camera3D = get_viewport().get_camera_3d()
@onready var _health_pool:StatPool = %HealthPool
@onready var _animation_player:AnimationPlayer = %AnimationPlayer
#endregion

#region State Vars
var _using_mouse:bool = true
var _can_take_damage:bool = true
var _is_diving:bool = false
var _dive_direction:Vector3 = Vector3.ZERO
var _dive_timer:float = 0.0
#endregion

#region Lifecycle
func _ready ():
	_hurtbox.body_entered.connect(_on_body_entered_hurtbox)
	_health_pool.set_max(_max_hp, {"fill": true})


func _physics_process(delta: float):
	## Need to build proper state machine
	if _is_diving:
		_handle_diving(delta)
	else:
		_handle_movement()
		_handle_aiming()
	
	move_and_slide()


func _unhandled_input(event: InputEvent):
	# Switch to mouse mode when mouse moves
	if event is InputEventMouseMotion:
		_using_mouse = true
	
	if event.is_action_pressed(Consts.INPUT.PLAYER.SHOOT):
		_fire_spell()
#endregion

#region Damage
func _on_body_entered_hurtbox (_body:Node3D):
	_take_damage()


func _take_damage ():
	if !_can_take_damage:
		return
	
	if !_debug_god_mode:
		_health_pool.decrease()
		EventBus.player_health_changed.emit(_health_pool.get_value())
		if _health_pool.is_empty():
			EventBus.player_died.emit()
	
	_audio_set.play_2d("take_damage")
	
	_can_take_damage = false
	await get_tree().create_timer(_damage_cooldown_in_seconds).timeout
	_can_take_damage = true
#endregion

#region Movement and Aiming
func _handle_movement():
	var input_direction = Input.get_vector(
		Consts.INPUT.PLAYER.MOVE.LEFT,
		Consts.INPUT.PLAYER.MOVE.RIGHT,
		Consts.INPUT.PLAYER.MOVE.UP,
		Consts.INPUT.PLAYER.MOVE.DOWN,
	)
	
	var movement_direction = Vector3(input_direction.x, 0, input_direction.y)
	
	if movement_direction.length() > _input_deadzone:
		velocity.x = movement_direction.x * _move_speed
		velocity.z = movement_direction.z * _move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, _move_speed)
		velocity.z = move_toward(velocity.z, 0, _move_speed)
	
	if velocity.normalized().length() > 0.1:
		_animation_player.play("sprint")
	else:
		_animation_player.play("idle")
	
	if Input.is_action_pressed("player_move_dive"):
		_start_dive(movement_direction)


func _handle_aiming():
	if _is_diving:
		return
	
	var stick_input = Input.get_vector(
		Consts.INPUT.PLAYER.AIM.LEFT,
		Consts.INPUT.PLAYER.AIM.RIGHT,
		Consts.INPUT.PLAYER.AIM.UP,
		Consts.INPUT.PLAYER.AIM.DOWN,
	)
	
	var aim_direction: Vector3
	
	if stick_input.length() > _aim_deadzone:
		_using_mouse = false
		aim_direction = Vector3(stick_input.x, 0, stick_input.y)
	elif _using_mouse:
		aim_direction = _get_mouse_aim_direction()
	elif velocity.length() > _input_deadzone:
		aim_direction = Vector3(velocity.x, 0, velocity.z)
	else:
		return
	
	if aim_direction.length() > 0.01:
		var target_rotation = atan2(-aim_direction.x, -aim_direction.z)
		rotation.y = target_rotation


func _get_mouse_aim_direction() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	
	var from = _camera.project_ray_origin(mouse_pos)
	var direction = _camera.project_ray_normal(mouse_pos)
	
	var plane = Plane(Vector3.UP, global_position.y)
	var intersection = plane.intersects_ray(from, direction)
	
	if intersection:
		var aim_point = intersection as Vector3
		var aim_direction = aim_point - global_position
		aim_direction.y = 0
		return aim_direction.normalized()
	
	return Vector3.ZERO
#endregion

#region Attack
func _fire_spell():
	# This needs implementing properly
	var projectile = _projectile_spawner.spawn() as Projectile
	projectile.global_transform = _projectile_spawn_point.global_transform
	projectile.init(_equipped_spell_def)
	projectile.on_spawn()
	_audio_set.play_2d("fire_spell")
#endregion

#region Dive State
func _start_dive(dive_direction:Vector3):
	if dive_direction.length() < _input_deadzone:
		return 
	
	_is_diving = true
	_dive_timer = 0.0
	_dive_direction = dive_direction
	rotation.y = atan2(-_dive_direction.x, -_dive_direction.z)
	_animation_player.play("dive")


func _handle_diving(delta:float):
	_dive_timer += delta
	var dive_completion_t = _dive_timer / _dive_duration
	
	if dive_completion_t >= 1.0:
		_end_dive()
		return
	
	var speed = _dive_speed_curve.sample(dive_completion_t) * (_dive_distance / _dive_duration)
	velocity = _dive_direction * speed


func _end_dive ():
	_is_diving = false
	velocity = Vector3.ZERO
	_animation_player.play("RESET")
#endregion
