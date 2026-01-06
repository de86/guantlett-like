extends CanvasLayer


@export var fade_in_over_seconds:float = 1.0
@export var pause_for_seconds:float = 2.0
@export var fade_out_over_seconds:float = 1.0

@onready var logoImage:TextureRect = %TextureRect


func _ready () -> void:
	logoImage.modulate.a = 0
	
	await create_tween().tween_property(logoImage, "modulate:a", 1, fade_in_over_seconds).finished	
	await get_tree().create_timer(pause_for_seconds).timeout
	await create_tween().tween_property(logoImage, "modulate:a", 0, fade_in_over_seconds).finished
	
	EventBus.splash_complete.emit()


func _input(event):
	if event is not InputEventMouseMotion:
		print(event.to_string())
		EventBus.splash_complete.emit()
