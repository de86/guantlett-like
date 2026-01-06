class_name SoundDef
extends Resource

# The audio stream to be played
@export var audio_stream:AudioStream

# Identifying key used when registering this sound def with the AudioManager
@export var name:StringName

# The audio bus to play the stream through. Defaults to &"SFX"
@export var bus:StringName

# The amount of variance in volume each time the stream is played
@export var volume_jitter:float

# Consider pitch being in a key...
# The amount of variance in pitch each time the stream is played
@export var pitch_jitter:float

# The maximum number of simultaneous streams of this sound effect
@export var max_polyphony:int
