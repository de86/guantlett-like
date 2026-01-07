class_name AudioEntry extends Resource
## A single audio entry that can play one sound or randomly select from multiple

@export var key: String = ""

@export var streams: Array[AudioStream] = []

@export var pitch_range: Vector2 = Vector2(1.0, 1.0)
@export var volume_db: float = 0.0
@export var max_distance: float = 50.0


func get_stream() -> AudioStream:
	if streams.is_empty():
		return null
	
	if streams.size() == 1:
		return streams[0]
	
	return streams[randi() % streams.size()]
