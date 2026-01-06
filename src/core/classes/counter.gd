extends RefCounted
class_name Counter

signal changed(new_value: int)
signal max_value_changed(new_max: int)
signal min_value_changed(new_max: int)

var _value:int = 0
var _min_value:int = Consts.INT.MIN
var _max_value:int = Consts.INT.MAX
var _use_signals:bool = true

func _init(
	start_value:int = 0,
	min_value:int = Consts.INT.MIN,
	max_value:int = Consts.INT.MAX,
	use_signals:bool = true,
):
	_min_value = min_value
	_max_value = max_value
	set_value(start_value)
	_use_signals = use_signals


func get_value() -> int:
	return _value


func set_value(value: int) -> void:
	var clamped = clamp(value, _min_value, _max_value)
	if clamped == _value:
		return
	
	_value = clamped
	
	if _use_signals:
		changed.emit(_value)


func change_value(value:int) -> int:
	var next_value = _value + value
	set_value(next_value)
	return _value


func reset(value: int = 0) -> int:
	set_value(value)
	return _value


func set_min(value: int) -> void:
	_min_value = value
	set_value(_value)
	
	if _use_signals:
		min_value_changed.emit(_min_value)


func get_min () -> int:
	return _min_value


func get_max () -> int:
	return _max_value


func set_max(value: int) -> void:
	_max_value = value
	set_value(_value)
	
	if _use_signals:
		max_value_changed.emit(_max_value)


func set_bounds(min_value: int, max_value: int) -> void:
	_min_value = min_value
	_max_value = max_value
	set_value(_value)
	
	if _use_signals:
		max_value_changed.emit(_max_value)
		min_value_changed.emit(_min_value)


func is_min() -> bool:
	return _value <= _min_value


func is_max() -> bool:
	return _value >= _max_value


func is_zero() -> bool:
	return _value == 0


func equals(value: int) -> bool:
	return _value == value


func greater_than(value: int) -> bool:
	return _value > value


func less_than(value: int) -> bool:
	return _value < value


func increment(amount: int = 1) -> int:
	set_value(_value + amount)
	return _value


func decrement(amount: int = 1) -> int:
	set_value(_value - amount)
	return _value


func peek_increment(amount: int = 1) -> int:
	return clamp(_value + amount, _min_value, _max_value)


func peek_decrement(amount: int = 1) -> int:
	return clamp(_value - amount, _min_value, _max_value)


func as_string() -> String:
	return str(_value)


func _to_string() -> String:
	return "Counter(value=%d, min=%d, max=%d)" % [_value, _min_value, _max_value]
