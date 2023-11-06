extends Area2D


func _ready():
	body_entered.connect(end)


func end(body):
	SceneTransition.close_screen()
	await SceneTransition.transition_halfway
	get_tree().change_scene_to_file("res://cutscenes/outro.tscn")
	SceneTransition.open_screen()
