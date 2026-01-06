@tool

extends Node


## Calls queue_free on all children of target node
## Returns: void
## Parameters:
## - target_node: Node - The Node to queue_free all children from
func queue_free_all_children_of_node (target_node:Node) -> void:
	for child in target_node.get_children():
		child.queue_free()


## Merges two options objects. user_opts will always override default_opts
## Returns: Dictionary[StringName, Variant]
## Parameters:
## - user_opts: Dictionary[StringName, Variant] - User defined options dictionary
## - default_opts: Dictionary[StringName, Variant] - Default options dictionary
func merge_options (user_opts:Dictionary[StringName, Variant], default_opts:Dictionary[StringName, Variant]) -> Dictionary[StringName, Variant]:
	var merged := default_opts.duplicate()
	merged.merge(user_opts, true)
	return merged


## Disables collision layers and masks on a node that supports collision
## Returns: void
## Parameters:
## - node: Node - The node to disable collision on
## - layers: Array[int] - Collision layers to disable
## - masks: Array[int] - Collision masks to disable
func disable_collision_layers (node: Node, layers: Array[int] = [], masks: Array[int] = []):
	_set_collision_values(node, false, layers, masks)
	for child in node.get_children():
		if child is CollisionShape3D:
			child.disabled = true


## Disables ALL collision layers and masks on a node that supports collision
## Returns: void
## Parameters:
## - node: Node - The node to disable collision on
func disable_all_collision (node: Node) -> void:
	if "collision_layer" in node:
		node.collision_layer = 0
	
	if "collision_mask" in node:
		node.collision_mask = 0


## Enables collision layers and masks on a node that supports collision
## Returns: void
## Parameters:
## - node: Node - The node to enable collision on
## - layers: Array[int] - Collision layers to enable
## - masks: Array[int] - Collision masks to enable
func enable_collision_layers (node: Node, layers: Array[int] = [], masks: Array[int] = []):
	_set_collision_values(node, true, layers, masks)


func _set_collision_values (node: Node, enabled: bool, layers: Array[int], masks: Array[int]):
	var has_masks := node.has_method("set_collision_mask_value")
	var has_layers := node.has_method("set_collision_layer_value")
	
	if not has_layers and not has_masks:
			push_warning("Node %s does not support collision layers/masks" % node.name)
			return
	
	if has_layers:
		for layer in layers:
			node.set_collision_layer_value(layer, enabled)
	
	if has_masks:
		for mask in masks:
			node.set_collision_mask_value(mask, enabled)
