extends CanvasLayer


@onready var _key_count:IconWithCount = %KeyCount
@onready var _heart_meter:IconMeterUI = %HeartMeter
@onready var _score_label:Label = %Label


func _init ():
	EventBus.player_collected_item.connect(_on_player_collected_item)
	EventBus.player_used_key.connect(_on_player_used_key)
	EventBus.player_health_changed.connect(_on_player_health_changed)
	EventBus.player_score_changed.connect(_on_player_scored_changed)


func _ready ():
	print("UI READY")


func _on_player_collected_item (item:SimpleItemDef):
	match item.id:
		&"small_key":
			_key_count.increment()


func _on_player_used_key ():
	_key_count.decrement()


func _on_player_health_changed (new_value:int):
	if _heart_meter:
		_heart_meter.set_value(new_value)


func _on_player_scored_changed (score:int):
	_score_label.text = str("Score: %s" %score)
