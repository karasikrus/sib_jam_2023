extends RigidBody2D
class_name BabyMouse

var is_teleporting = false
var teleport_location: Vector2 = Vector2.ZERO

func _integrate_forces(state):
	if is_teleporting:
		is_teleporting = false
		state.transform.origin = teleport_location
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0

func teleport(location: Vector2):
	teleport_location = location
	is_teleporting = true
