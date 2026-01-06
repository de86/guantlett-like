class_name MoveToTargetMovementBehaviourDef extends BaseMovementBehaviourDef


@export var _move_speed:float = 1.0


func move (body:Node, _delta:float, args:Dictionary[StringName, Variant]):
	var valid_args:Dictionary[StringName, Variant] = validate_args(args)
	if !valid_args:
		push_warning("Arguments provided to movement behaviour are not valid")
		return
	
	var direction:Vector3 = args.follow_target.global_position - body.global_position
	direction.y = 0
	
	if direction.length() > 0.3:
		direction = direction.normalized()
		
		body.velocity.x = direction.x * _move_speed
		body.velocity.z = direction.z * _move_speed
		
		var target_rotation = atan2(-direction.x, -direction.z)
		body.rotation.y = target_rotation
	else:
		body.velocity.x = 0
		body.velocity.y = 0
	
	body.move_and_slide()


func validate_args (args:Dictionary[StringName, Variant]) -> Dictionary[StringName, Variant]:
	if !(&"follow_target" in args):
		push_warning("follow_target arg missing")
		return {}
	
	if !args.get(&"follow_target") is Node3D:
		push_warning("follow_target must be of type Vector3")
		return {}
	
	return args
