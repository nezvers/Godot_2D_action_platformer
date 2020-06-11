extends Node2D

var time_scale: = 1.0
func set_time_scale(value:float)->void:
	time_scale = clamp(value, 0.1, 2.0)
	print("TIME: ", time_scale)

func _unhandled_input(event):
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	elif event.is_action_pressed("click"):
		var player = find_node("Player")
		player.damage(sign((player.position - get_local_mouse_position()).x))
	elif event.is_action_pressed("ui_page_down"):
		set_time_scale(time_scale-0.1)
		Engine.time_scale = time_scale
	elif event.is_action_pressed("ui_page_up"):
		set_time_scale(time_scale+0.1)
		Engine.time_scale = time_scale
