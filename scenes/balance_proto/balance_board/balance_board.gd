extends CharacterBody2D
class_name BalanceBoard

var balance_point : float = 0 # from -1 to 1
var x_dir
@export var balance_tilt_force : float = 0.02
@export var balance_reset_force : float = 0.01
@export var max_angle : float = 30

@export_category("Magnetic field")
@export var is_magnetic_field_active : bool = false
@export var magnetic_field_power : float = 10
var is_applying_magnetic_force : bool = false
var baby_mouse : BabyMouse

@export_category("Baby mouse inertia")
@export var standard_baby_mouse_inertia : float = 50
@export var close_baby_mouse_inertia : float = 500



@onready var magnetic_field = $MagneticField as Area2D

func _ready():
	magnetic_field.body_entered.connect(on_body_entered_magnetic_field)
	magnetic_field.body_exited.connect(on_body_exited_magnetic_field)


func get_input() -> Dictionary:
	return {
		"x": int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		"y": int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up")),
		"just_jump": Input.is_action_just_pressed("jump") == true,
		"jump": Input.is_action_pressed("jump") == true,
		"released_jump": Input.is_action_just_released("jump") == true
	}

func _physics_process(delta):
	balance_movement(delta)
	tilt_board()
	apply_magnetic_force()


func balance_movement(delta):
	x_dir = get_input()["x"]
	
	#reset to staring position
	if balance_point > 0 and x_dir <= 0:
		balance_point = clampf(balance_point - balance_reset_force * delta, 0, 1)
	elif balance_point < 0 and x_dir >= 0:
		balance_point = clampf(balance_point + balance_reset_force * delta, -1, 0)
		
	#tilt forward
	balance_point = clampf(balance_point + balance_reset_force * delta * x_dir, -1, 1)

func tilt_board():
	var weight : float = (balance_point + 1)/2 # from -1 to 1 -> from 0 to 1
	var left_tilt = deg_to_rad(-max_angle)
	var right_tilt = deg_to_rad(max_angle)
	var angle = lerp_angle(left_tilt, right_tilt, weight)
	
	rotation = angle

func apply_magnetic_force():
	if !is_applying_magnetic_force:
		return
	
	var force = (magnetic_field.global_position - baby_mouse.global_position)\
			.normalized() * magnetic_field_power
	baby_mouse.apply_force(force)

func on_body_entered_magnetic_field(body):
	if body is BabyMouse:
		baby_mouse = (body as BabyMouse)
		baby_mouse.inertia = close_baby_mouse_inertia
		baby_mouse.make_not_alone()
	if !is_magnetic_field_active:
		return
		
	is_applying_magnetic_force = true


func on_body_exited_magnetic_field(body):
	if body is BabyMouse:
		baby_mouse = (body as BabyMouse)
		baby_mouse.inertia = standard_baby_mouse_inertia
		baby_mouse.make_alone()
	if !is_magnetic_field_active:
		return
	is_applying_magnetic_force = false
