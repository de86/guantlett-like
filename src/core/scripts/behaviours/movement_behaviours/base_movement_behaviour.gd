class_name BaseMovementBehaviourDef extends Resource

func move (body:Node, delta:float, args:Dictionary[StringName, Variant]):
	push_error("BaseMovementBehaviour.move should be overriden")
