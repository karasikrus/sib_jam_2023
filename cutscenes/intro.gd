extends TextureRect

@export var path_to_next_scene: String = "res://scenes/balance_proto/Game_Level.tscn"


func on_end():
	SceneTransition.close_screen()
	await SceneTransition.transition_halfway
	get_tree().change_scene_to_file(path_to_next_scene)
	SceneTransition.open_screen()
