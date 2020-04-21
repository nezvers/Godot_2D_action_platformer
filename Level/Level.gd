extends Node2D

func _unhandled_input(event):
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	if event.is_action_pressed("click"):
		var player = find_node("Player")
		player.damage(sign((player.position - get_local_mouse_position()).x))
