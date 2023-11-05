extends Area2D

@export var launch_force_y: float = -1000

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body is CharacterBody2D :
		var launch_direction_rotation : float = $CollisionShape2D.global_rotation;
		(body as CharacterBody2D).velocity.x = - launch_force_y * sin(launch_direction_rotation)
		(body as CharacterBody2D).velocity.y = launch_force_y * cos(launch_direction_rotation)
		
