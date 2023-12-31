extends CharacterBody2D

# BASIC MOVEMENT VARAIABLES ---------------- #
var face_direction := 1
var x_dir := 1

@export var max_speed: float = 560
@export var acceleration: float = 2880
@export var turning_acceleration : float = 9600
@export var deceleration: float = 3200

@export_category("default acceleraion")
@export var default_acceleration: float = 2880
@export var default_turning_acceleration : float = 9600
@export var default_deceleration: float = 3200

@export_category("ice acceleraion")
@export var ice_acceleration: float = 2880/8
@export var ice_turning_acceleration : float = 9600/8
@export var ice_deceleration: float = 3200/8

@export_category("air acceleraion")
@export var air_acceleration: float = 2880
@export var air_turning_acceleration : float = 9600
@export var air_deceleration: float = 1000
@export_category("")
# ------------------------------------------ #

# GRAVITY ----- #
@export var gravity_acceleration : float = 3840
@export var gravity_max : float = 1020
# ------------- #

# JUMP VARAIABLES ------------------- #
var jump_force : float = 1400
@export var default_jump_force : float = 1400
@export var powerful_jump_force : float = 1400 * 3

@export var jump_cut : float = 0.25
@export var jump_gravity_max : float = 500
@export var jump_hang_treshold : float = 2.0
@export var jump_hang_gravity_mult : float = 0.1
# Timers
@export var jump_coyote : float = 0.3
@export var jump_buffer : float = 0.1

var jump_coyote_timer : float = 0
var jump_buffer_timer : float = 0
var is_jumping := false
var was_near_floor := false
# ----------------------------------- #
@onready var area_2d = $Area2D
@onready var board_top_location = $BoardTopLocation
@onready var ray_cast_2d = $BottomRays/RayCast2D
@onready var ray_cast_2d_2 = $BottomRays/RayCast2D2
@onready var ray_cast_2d_3 = $BottomRays/RayCast2D3
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite
# AUDIO ----------------------------- # 
@onready var steps_audio_player = $StepsAudioPlayer as RandomAudioStreamPlayer
@onready var jump_audio_stream_player = $JumpAudioStreamPlayer as RandomAudioStreamPlayer
@onready var landing_audio_stream_player = $LandingAudioStreamPlayer as RandomAudioStreamPlayer

# ----------------------------------- # ice ray casts
@onready var ice_ray_1 = $BottomRays/IceRays/IceRay1
@onready var ice_ray_2 = $BottomRays/IceRays/IceRay2

# ----------------------------------- # web ray casts
@onready var web_ray_1 = $BottomRays/WebRays/WebRay1
@onready var web_ray_2 = $BottomRays/WebRays/WebRay2




func _ready():
	area_2d.body_entered.connect(on_body_near_legs)


func _process(delta):
	animate()


func on_body_near_legs(body: Node2D):
	if body is BabyMouse and is_pickup_near_floor():
		(body as BabyMouse).teleport(board_top_location.global_position)


func is_near_floor():
	return ray_cast_2d.is_colliding()


func is_pickup_near_floor():
	return ray_cast_2d.is_colliding() or\
	ray_cast_2d_2.is_colliding() or\
	ray_cast_2d_3.is_colliding()
	
	
	
# All iputs we want to keep track of
func get_input() -> Dictionary:
	return {
		"x": int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		"y": int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up")),
		"just_jump": Input.is_action_just_pressed("jump") == true,
		"jump": Input.is_action_pressed("jump") == true,
		"released_jump": Input.is_action_just_released("jump") == true
	}


func _physics_process(delta: float) -> void:
	update_acceleration()
	update_jump_force()
	x_movement(delta)
	jump_logic(delta)
	apply_gravity(delta)
	
	timers(delta)
	move_and_slide()
	check_landing()


func check_landing():
	if !was_near_floor && is_near_floor():
		landing_audio_stream_player.play_random()
	was_near_floor = is_near_floor()


func x_movement(delta: float) -> void:
	x_dir = get_input()["x"]
	
	# Stop if we're not doing movement inputs.
	if x_dir == 0: 
		velocity.x = Vector2(velocity.x, 0).move_toward(Vector2(0,0), deceleration * delta).x
		return
	
	# If we are doing movement inputs and above max speed, don't accelerate nor decelerate
	# Except if we are turning
	# (This keeps our momentum gained from outside or slopes)
	if abs(velocity.x) >= max_speed and sign(velocity.x) == x_dir:
		return
	
	# Are we turning?
	# Deciding between acceleration and turn_acceleration
	var accel_rate : float = acceleration if sign(velocity.x) == x_dir else turning_acceleration
	
	# Accelerate
	velocity.x += x_dir * accel_rate * delta
	
	set_direction(x_dir) # This is purely for visuals


func set_direction(hor_direction) -> void:
	# This is purely for visuals
	# Turning relies on the scale of the player
	# To animate, only scale the sprite
	if hor_direction == 0:
		return
	#apply_scale(Vector2(hor_direction * face_direction, 1)) # flip
	#face_direction = hor_direction # remember direction


func jump_logic(_delta: float) -> void:
	# Reset our jump requirements
	if is_on_floor():
		jump_coyote_timer = jump_coyote
		is_jumping = false
	if get_input()["just_jump"]:
		jump_buffer_timer = jump_buffer
	
	# Jump if grounded, there is jump input, and we aren't jumping already
	if jump_coyote_timer > 0 and jump_buffer_timer > 0 and not is_jumping:
		is_jumping = true
		jump_audio_stream_player.play_random()
		jump_coyote_timer = 0
		jump_buffer_timer = 0
		# If falling, account for that lost speed
		if velocity.y > 0:
			velocity.y -= velocity.y
		
		velocity.y = -jump_force
	
	# We're not actually interested in checking if the player is holding the jump button
#	if get_input()["jump"]:pass
	
	# Cut the velocity if let go of jump. This means our jumpheight is varaiable
	# This should only happen when moving upwards, as doing this while falling would lead to
	# The ability to studder our player mid falling
	if get_input()["released_jump"] and velocity.y < 0:
		velocity.y -= (jump_cut * velocity.y)
	
	# This way we won't start slowly descending / floating once hit a ceiling
	# The value added to the treshold is arbritary,
	# But it solves a problem where jumping into 
	if is_on_ceiling(): velocity.y = jump_hang_treshold + 100.0


func apply_gravity(delta: float) -> void:
	var applied_gravity : float = 0
	
	# No gravity if we are grounded
	if is_on_floor():
		return
	
	# Normal gravity limit
	if velocity.y <= gravity_max:
		applied_gravity = gravity_acceleration * delta
	
	# If moving upwards while jumping, the limit is jump_gravity_max to achieve lower gravity
	if (is_jumping and velocity.y < 0) and velocity.y > jump_gravity_max:
		applied_gravity = 0
	
	# Lower the gravity at the peak of our jump (where velocity is the smallest)
	if is_jumping and abs(velocity.y) < jump_hang_treshold:
		applied_gravity *= jump_hang_gravity_mult
	
	velocity.y += applied_gravity


func timers(delta: float) -> void:
	# Using timer nodes here would mean unnececary functions and node calls
	# This way everything is contained in just 1 script with no node requirements
	jump_coyote_timer -= delta
	jump_buffer_timer -= delta


func animate():
	if x_dir > 0:
		sprite.scale.x = -abs(sprite.scale.x)
	elif x_dir < 0:
		sprite.scale.x = abs(sprite.scale.x)
	if is_near_floor() && !is_jumping:
		if velocity.x > 0:		
			animation_player.play("walk")
		elif velocity.x < 0:		
			animation_player.play("walk")
		elif velocity.x == 0:
			animation_player.play("idle")
	else:
		if velocity.y > 0:
			animation_player.play("fall")
		if velocity.y < 0:
			animation_player.play("jump")


func play_step_sound():
	steps_audio_player.play_random()


func update_acceleration():
	if !is_near_floor():
		acceleration = air_acceleration
		deceleration = air_deceleration
		turning_acceleration = air_turning_acceleration
	elif ice_ray_1.is_colliding() or ice_ray_2.is_colliding(): #on ice and on floor
		acceleration = ice_acceleration
		deceleration = ice_deceleration
		turning_acceleration = ice_turning_acceleration
	else:
		acceleration = default_acceleration
		deceleration = default_deceleration
		turning_acceleration = default_turning_acceleration


func update_jump_force():
	if web_ray_1.is_colliding() or web_ray_2.is_colliding(): #on ice and on floor
		jump_force = powerful_jump_force
	else:
		jump_force = default_jump_force
