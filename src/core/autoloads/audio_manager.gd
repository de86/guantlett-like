extends Node


var audio_registry:Dictionary[StringName, SoundDef] = {}


func register_sound_def (sound_def:SoundDef) -> void:
	audio_registry.set(sound_def.name, sound_def)


func play_sfx (sound_def_key:StringName) -> void:
	var sound_def:SoundDef = audio_registry.get(sound_def_key)
	var streamPlayer = AudioStreamPlayer.new()
	streamPlayer.bus = sound_def.bus
	add_child(streamPlayer)
	streamPlayer.stream = sound_def.audio_stream
	streamPlayer.play()
