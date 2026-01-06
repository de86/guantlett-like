class_name click_detector
extends Area2D


signal clicked


func _input_event (viewport:Viewport, event:InputEvent, index:int):
	if event is InputEventMouseButton and event.is_pressed():
		clicked.emit()
