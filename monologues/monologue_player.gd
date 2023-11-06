extends CanvasLayer
class_name MonologuePlayer

@export var monologues : Array[Monologue] = []

var is_timer_active = false
var timer : float = 0




func start_timer():
	timer = 0
	is_timer_active = true


func update_timer(delta):
	timer+=delta
