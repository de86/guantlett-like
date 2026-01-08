@tool

class_name ItemPickup
extends Node3D


@export var _simple_item_registry:SimpleItemRegistryDef
@export var _item:SimpleItemDef:
	set(value):
		_item = value
		_update_visual()


@onready var _visual_root:Node3D = %VisualRoot
@onready var _area_3d:Area3D = %Area3D


var _visual_instance:Node3D


func _ready ():
	_area_3d.body_entered.connect(_on_player_collision)
	_update_visual()


func _on_player_collision (body):
	if !body is Player:
		print(body)
		return
	
	if !_item:
		push_warning("Player collided with Pickup Item but not item data set")
	
	if !_item.on_pickup_action:
		push_warning("No onPickUpAction set for item %s" %_item.display_name)
	
	_item.on_pickup_action.execute(_item)
	# Particle FX
	
	if _item.audio_set:
		_item.audio_set.play_2d("sfx_pickup")
	
	queue_free()


func _update_visual ():
	if !_visual_root:
		push_warning("visual_root node not found in scene %s" %self.name)
		return
	
	if !_item:
		push_warning("No item data given")
		Utils.queue_free_all_children_of_node(_visual_root)
		if _visual_root and _visual_root.get_children().size() > 0:
			Utils.queue_free_all_children_of_node(_visual_root)
		return
	
	if !_item.visual:
		push_warning("Item data does not contain visual")
		if _visual_root and _visual_root.get_children().size() > 0:
			Utils.queue_free_all_children_of_node(_visual_root)
		return
	
	_visual_instance = _item.visual.instantiate()
	_visual_root.add_child(_visual_instance)
	
	if !Engine.is_editor_hint():
		_visual_instance.owner = get_tree().edited_scene_root


func _get_property_list():
	var names := []
	if _simple_item_registry:
		for item in _simple_item_registry.simple_items:
			names.append(item.display_name)
	
	return []
