extends Node3D


@onready var _exit_trigger:Area3D = %ExitTrigger
@onready var _key_check_trigger:Area3D = %KeyCheckTrigger
@onready var _trapdoor_visual:Node3D = %TrapDoor


func _ready ():
	_exit_trigger.body_entered.connect(_on_body_entered_exit_trigger)
	_key_check_trigger.body_entered.connect(_on_body_entered_key_check_trigger)


func _on_body_entered_exit_trigger (body:Node3D):
	if body is Player:
		EventBus.player_exited_floor.emit()


func _on_body_entered_key_check_trigger (body:Node3D):
	if body is Player:
		if GameState._player_has_exit_key:
			_trapdoor_visual.visible = false
