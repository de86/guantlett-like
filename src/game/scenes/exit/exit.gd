extends Node3D


@export var _audio_set:AudioSet


@onready var _exit_trigger:Area3D = %ExitTrigger
@onready var _key_check_trigger:Area3D = %KeyCheckTrigger
@onready var _trapdoor_visual:Node3D = %TrapDoor
@onready var _animation_player:AnimationPlayer = %AnimationPlayer


var _is_open:bool = false


func _ready ():
	_exit_trigger.body_entered.connect(_on_body_entered_exit_trigger)
	_key_check_trigger.body_entered.connect(_on_body_entered_key_check_trigger)


func _on_body_entered_exit_trigger (body:Node3D):
	if body is Player:
		EventBus.player_exited_floor.emit()


func _on_body_entered_key_check_trigger (body:Node3D):
	if _is_open:
		return
	
	if body is Player:
		if !GameState._player_has_exit_key:
			_animation_player.play("exit_locked")
			_audio_set.play_2d("locked_door_rattle")
			return
		
		_animation_player.play("exit_open")
		_is_open = true


## Called from animation player
func _play_sfx (name:String):
	_audio_set.play_2d(name)
