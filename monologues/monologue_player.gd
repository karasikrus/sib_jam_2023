extends CanvasLayer

@export var monologues : Array[Monologue] = []
@onready var label = %Label
@onready var audio_stream_player = %AudioStreamPlayer
@onready var boring_timer = $BoringTimer

var is_timer_active = false
var timer : float = 0
var played: Array[bool] = []

func _ready():
	audio_stream_player.finished.connect(on_dialogue_end)
	boring_timer.timeout.connect(play_boring_phrase)
	played.resize(monologues.size())
	played.fill(false)
	

#func _process(delta):
#	if Input.is_action_just_pressed("jump"):
#		play_monologue(0)

func play_monologue(id: int) -> bool:
	if id >= monologues.size():
		return false
	if played[id]:
		return false
	if audio_stream_player.playing:
		return false
	played[id] = true
	var mono = monologues[id] as Monologue
	label.text = mono.phrase_texts[0]
	audio_stream_player.stream = mono.phrase_audio
	audio_stream_player.play()
	visible = true
	boring_timer.start()
	return true
	
func on_dialogue_end():
	visible = false

func start_timer():
	timer = 0
	is_timer_active = true


func update_timer(delta):
	timer+=delta

var boring_id : int = 6
func play_boring_phrase():
	var success = play_monologue(boring_id)
	boring_timer.start()
	if success:
		boring_id+=1
