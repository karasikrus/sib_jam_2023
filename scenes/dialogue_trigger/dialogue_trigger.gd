extends Area2D

@export var monologue_id: int = 0

var play_dialogue = false
func _ready():
	body_entered.connect(on_enter)


func _process(delta):
	if play_dialogue:
		var success = MonologuePlayer.play_monologue(monologue_id)
		if success:
			play_dialogue = false

func on_enter(body):
	play_dialogue = true
