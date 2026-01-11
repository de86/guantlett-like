class_name TimedSpawnerDef extends Resource

## The object resource that should be spawned
@export var spawn_resource:SimpleMobDef

## Spawns happen at a regular interval when true.
@export var spawn_automatically:bool = false

## Time between spawn when spawn_automatically is true.
@export var spawn_interval_seconds:float = 0.0

## Spawning stops after this many objects are spawned 
@export var spawn_limit:int = 0

## The pool resource that this spawner should pull spawn objects from
@export var pool_def:PoolDef
