extends RigidBody2D
class_name BabyMouse

var is_teleporting = false
var last_frame_teleported = false
var teleport_location: Vector2 = Vector2.ZERO

@export var default_friction = 1
@export var ice_friction = 0.001

@onready var ray_cast_2d = $RayCast2D
@onready var audio_stream_player_2d = $AudioStreamPlayer2D
@onready var animation_player = $AnimationPlayer
@onready var hit_timer = $HitTimer
@onready var alone_timer = $AloneTimer
@onready var random_cry_player_2d = $RandomCryPlayer2D as RandomAudioStreamPlayer2D
@onready var random_laugh_player_2d = $RandomLaughPlayer2D as RandomAudioStreamPlayer2D

var is_alone := false

func _ready():
	body_entered.connect(on_collision)
	alone_timer.timeout.connect(on_alone_timer_end)

func play_cry_sound():
	var i = randi_range(0,3)
	if i == 0:
		random_cry_player_2d.play_random_if_not_playing()
		random_laugh_player_2d.stop()


func play_laugh_sound():
	random_laugh_player_2d.play_random_if_not_playing()
	random_cry_player_2d.stop()


func _process(delta):
	update_animations()


func _physics_process(delta):
	ray_cast_2d.global_rotation = 0.0
	if ray_cast_2d.is_colliding():
		physics_material_override.friction = ice_friction
	else:
		physics_material_override.friction = default_friction

func _integrate_forces(state):
	if is_teleporting:
		is_teleporting = false
		state.transform.origin = teleport_location
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
		last_frame_teleported = true
	if last_frame_teleported:
		last_frame_teleported = false
		state.transform.origin = teleport_location
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0

func teleport(location: Vector2):
	teleport_location = location
	is_teleporting = true


func update_animations():
	if hit_timer.time_left > 0:
		animation_player.play("hit")
	elif  is_alone:
		animation_player.play("crying")
	else:
		animation_player.play("default")


func on_collision(body:Node):
	if body.is_in_group("dirt"):
		audio_stream_player_2d.play()
		hit_timer.start()
		if alone_timer.time_left > 0:
			alone_timer.start()


func make_alone():
	alone_timer.start()


func make_not_alone():
	alone_timer.stop()
	is_alone = false
	random_cry_player_2d.stop()

func on_alone_timer_end():
	is_alone = true
