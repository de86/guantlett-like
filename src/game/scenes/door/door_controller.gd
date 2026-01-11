extends Node3D


@export var _audio_set:AudioSet


@onready var _lock_check_trigger:Area3D = %LockCheckTrigger
@onready var _lock_check_trigger_collision_shape:CollisionShape3D = %LockCheckCollisionShape3D
@onready var _static_body_collision_shape:CollisionShape3D = %CollisionShape3D
@onready var _animation_player:AnimationPlayer = %AnimationPlayer


func _ready ():
	_lock_check_trigger.body_entered.connect(_on_body_entered)


func _on_body_entered (body: Node3D):
	if body is Player:
		if !GameState.player_has_key():
			_animation_player.play("door_locked")
			_audio_set.play_2d("locked_door_rattle")
			return
			
		_static_body_collision_shape.set_deferred("disabled", true)
		_lock_check_trigger_collision_shape.set_deferred("disabled", true)
		_lock_check_trigger.body_entered.disconnect(_on_body_entered)
		_animation_player.play("door_open")


func _play_sfx (name:String):
	_audio_set.play_2d(name)
