class_name StatPool extends Node


signal statpool_value_changed
signal statpool_max_changed
signal statpool_full
signal statpool_empty
signal statpool_reset


@export var _max_statpool_value = 6


@onready var _statpool_counter:Counter = Counter.new(_max_statpool_value, 0, _max_statpool_value, false)
@onready var _initial_max_statpool_value = _max_statpool_value


#region Public API
func increase (value:int = 1) -> int:
	var new_value = _statpool_counter.increment(value)
	statpool_value_changed.emit(new_value)
	
	return new_value


func decrease (value:int = 1) -> int:
	var new_value = _statpool_counter.decrement(value)
	statpool_value_changed.emit(new_value)
	
	return new_value


func change_value_by (value:int) -> int:
	var new_value = _statpool_counter.change_value(value)
	statpool_value_changed.emit(new_value)
	
	return new_value


func set_max (value:int, options:Dictionary[StringName, bool]) -> int:
	_statpool_counter.set_max(value)
	statpool_max_changed.emit(value)
	
	if options.fill:
		fill()
	
	return _statpool_counter.get_value()


func fill () -> int:
	_statpool_counter.set_value(_max_statpool_value)
	statpool_value_changed.emit(_statpool_counter.get_value())
	statpool_full.emit()
	
	return _statpool_counter.get_value()


func empty () -> void:
	_statpool_counter.set_value(0)
	statpool_value_changed.emit(_statpool_counter.get_value())
	statpool_empty.emit()


func reset () -> void:
	_statpool_counter.set_max(_initial_max_statpool_value)
	_statpool_counter.set_value(_initial_max_statpool_value)
	statpool_reset.emit()


func is_full () -> bool:
	return _statpool_counter.get_value() >= _max_statpool_value


func is_empty () -> bool:
	return _statpool_counter.is_zero()


func get_value () -> int:
	return _statpool_counter.get_value()
#endregion


#region Lifecycle
func _ready () -> void:
	_statpool_counter.set_value(_max_statpool_value)
#endregion
