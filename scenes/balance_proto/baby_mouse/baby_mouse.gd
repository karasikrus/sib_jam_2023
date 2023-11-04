extends RigidBody2D
class_name BabyMouse

var is_teleporting = false
var teleport_location: Vector2 = Vector2.ZERO

func _integrate_forces(state):
	if is_teleporting:
		state.transform.origin = teleport_location
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
		is_teleporting = false

func teleport(location: Vector2):
	is_teleporting = true
	teleport_location = location
