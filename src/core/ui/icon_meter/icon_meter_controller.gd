class_name IconMeterUI extends HBoxContainer


@export var _icon:Texture2D
@export var _empty_icon:Texture2D


var _meter_pieces:Array[TextureRect]
var _max_size = 5


func _ready ():
	init(_max_size)


func init (max_size:int):
	Utils.queue_free_all_children_of_node(self)
	for i in range(max_size):
		_create_meter_piece()


func _create_meter_piece ():
	var meter_piece = TextureRect.new()
	meter_piece.texture = _icon
	meter_piece.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	add_child(meter_piece)
	_meter_pieces.push_back(meter_piece)


func set_value (new_value: int):
	if new_value > _meter_pieces.size():
		_create_meter_piece()
	
	for i in _meter_pieces.size():
		if i+1 <= new_value:
			if _meter_pieces[i].texture != _icon:
				_meter_pieces[i].texture = _icon
		else:
			if _meter_pieces[i].texture != _empty_icon:
				_meter_pieces[i].texture = _empty_icon
