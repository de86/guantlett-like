## ActionDef is effectively the same implementation as BehaviourDef.
## BehaviourDef is intended for logic that is run inside of process or physics_process
## ActionDef is intended for one-shot execution of logic such as reacting to a signal
## The difference is purely semantic
class_name ActionDef extends Resource


func execute (_item:SimpleItemDef):
	push_warning("ActionDef resource is base resource and should extended. Please make sure execute is overriden in extending class.")
	pass
