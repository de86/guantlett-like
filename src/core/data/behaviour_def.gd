## BehaviourDef is effectively the same implementation as ActionDef.
## BehaviourDef is intended for logic that is run inside of process or physics_process
## ActionDef is intended for one-shot execution of logic such as reacting to a signal
## The difference is purely semantic
class_name BehaviourDef extends Resource

func execute ():
	push_warning("BehaviourDef resource is base resource and should extended. Please make sure execute is overriden in extending class.")
	pass
