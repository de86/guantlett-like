extends Node


@onready var _player_key_qty:Counter = Counter.new()


var _player_has_exit_key:bool = false


func _init ():
	EventBus.player_collected_item.connect(_on_player_collected_item)
	EventBus.player_used_key.connect(_on_player_used_key)


func _on_player_collected_item (item:SimpleItemDef):
	match item.id:
		&"small_key":
			_player_key_qty.increment()
			print(_player_key_qty.get_value())
		&"large_key":
			_player_has_exit_key = true
			print(_player_has_exit_key)


func _on_player_used_key ():
	_player_key_qty.decrement()
	print(_player_key_qty.get_value())


func player_has_key () -> bool:
	return _player_key_qty.greater_than(0)
