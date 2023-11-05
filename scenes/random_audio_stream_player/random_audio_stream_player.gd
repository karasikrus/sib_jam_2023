extends AudioStreamPlayer
class_name RandomAudioStreamPlayer

@export var audio_streams : Array[AudioStream]


func play_random():
	stream = audio_streams.pick_random()
	play()
