extends CharacterBody2D
class_name BalanceBoard

var balace_point : float = 0 # from -1 to 1
var x_dir
@export var balance_tilt_force : float = 0.02
@export var balance_reset_force : float = 0.01
@export var max_angle : float = 30

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


func balance_movement(delta):
	x_dir = get_input()["x"]
	
	#reset to staring position
	if x_dir == 0:
		if balace_point > 0:
			balace_point = clampf(balace_point - balance_reset_force * delta, 0, 1)
		if balace_point < 0:
			balace_point = clampf(balace_point + balance_reset_force * delta, -1, 0)
			
	else: #tilt forward
		balace_point = clampf(balace_point + balance_reset_force * delta * x_dir, -1, 1)

func tilt_board():
	var weight : float = (balace_point + 1)/2 # from -1 to 1 -> from 0 to 1
	var left_tilt = deg_to_rad(-max_angle)
	var right_tilt = deg_to_rad(max_angle)
	var angle = lerp_angle(left_tilt, right_tilt, weight)
	
	rotation = angle
