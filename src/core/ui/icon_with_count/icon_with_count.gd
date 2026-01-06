@tool
class_name IconWithCount
extends HBoxContainer

signal count_changed

## The icon to be displayed
@export var _icon:Texture2D:
	set(value):
		_icon = value
		call_deferred("_update_icon")

## The margin above both the icon and its count
@export var _margin_top:int:
	set(value):
		_margin_top = value
		call_deferred("_update_margins")

## The left margin
@export var _margin_right:int:
	set(value):
		_margin_right = value
		call_deferred("_update_margins")

## The margin below both the icon and its count
@export var _margin_bottom:int:
	set(value):
		_margin_bottom = value
		call_deferred("_update_margins")

## The right margin
@export var _margin_left:int:
	set(value):
		_margin_left = value
		call_deferred("_update_margins")

## The Margin between the icon and its count
@export var _margin_between:int:
	set(value):
		_margin_between = value
		call_deferred("_update_margins")


@onready var _texture_rect_margin_container:MarginContainer = %TextureRectMarginContainer
@onready var _texture_rect:TextureRect = %TextureRect
@onready var _label_margin_container:MarginContainer = %LabelMarginContainer
@onready var _label:Label = %Label
@onready var _counter = Counter.new()


func _ready ():
	_update_icon()
	_update_margins()
	_counter.reset()


func _update_icon ():
	if !is_inside_tree():
		push_warning("Scene tree is not ready. Aborting icon update.")
		return
	
	if !_icon:
		push_warning("icon not set for %s" %name)
	
	_texture_rect.texture = _icon


func _update_margins ():
	if !is_inside_tree():
		push_warning("Scene tree is not ready. Aborting icon update.")
		return
	
	# Top
	_texture_rect_margin_container.add_theme_constant_override("margin_top", _margin_top)
	_label_margin_container.add_theme_constant_override("margin_top", _margin_top)
	
	# Right
	_label_margin_container.add_theme_constant_override("margin_right", _margin_right)
	
	# Bottom
	_texture_rect_margin_container.add_theme_constant_override("margin_bottom", _margin_bottom)
	_label_margin_container.add_theme_constant_override("margin_bottom", _margin_bottom)
	
	# Left
	_texture_rect_margin_container.add_theme_constant_override("margin_left", _margin_left)
	
	# Between
	var margin_between = int(float(_margin_between)/2)
	_texture_rect_margin_container.add_theme_constant_override("margin_right", margin_between)
	_label_margin_container.add_theme_constant_override("margin_left", margin_between)


func increment (value = 1):
	if !value is int:
		push_warning("counter failed to increment. set_count value must be of type int")
		return
	
	var count = _counter.increment(value)
	_set_label_text(count)
	count_changed.emit(count)


func decrement (value = 1):
	if !value is int:
		push_warning("counter failed to decrement. set_count value must be of type int")
		return
	
	var count = _counter.decrement(value)
	_set_label_text(count)
	count_changed.emit(count)


func set_count (value):
	if !value is int:
		push_warning("Failed to set count. set_count value must be of type int")
		return
	
	_counter.set_value(value)
	_set_label_text(value)
	count_changed.emit(value)


func reset_count ():
	var count = _counter.reset()
	_set_label_text(count)
	count_changed.emit(count)


func _set_label_text (value):
	var text = str(value)
	_label.text = text
