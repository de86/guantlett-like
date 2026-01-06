class_name Orange
extends Node2D


signal clicked

@onready var _click_detector:click_detector = %ClickDetector

var _sfx_click = preload("res://src/game/data/sound/sfx_click.tres")


func _init ():
	_click_detector.clicked.connect(_on_click)


func _ready () -> void:
	AudioManager.register_sound_def(_sfx_click)


func _on_click () -> void:
	AudioManager.play_sfx(_sfx_click.name)
	clicked.emit()
