extends AudioStreamPlayer2D
class_name RandomAudioStreamPlayer2D

@export var streams : Array[AudioStream]

func play_random():
	stream = streams.pick_random()
	play()
