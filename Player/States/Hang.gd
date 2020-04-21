extends PlayerState

var dir: = 0.0

func unhandled_input(event:InputEvent)->void:
	if event.is_action_pressed("move_up") && player.up <= 0.01:
		player.up = event.get_action_strength("move_up")
		next_state = {state = "Climb", msg = {dir = dir}}
	elif event.is_action_pressed("move_down") && player.down <= 0.01:
		player.down = event.get_action_strength("move_down")
		next_state = {state = "Jump_top", msg = {}}
	else:
		player.unhandled_input(event)

func process(delta:float)->void:
	state_check()

func state_check()->void:
	if !next_state.empty():
		_state_machine.transition_to(next_state.state, next_state.msg)
		next_state = {}
	if player.jump:
		if sign(player.direction) != sign(player.body.scale.x):
			player.jump = true
			player.is_jumping = true
			player.velocity.y = player.jump_speed
			player.velocity.x = sign(player.direction) * player.wall_jmp_speed
			_state_machine.transition_to("Jump_wall", {})

func enter(msg:Dictionary = {})->void:
	animation.play("Hang")
	dir = player.direction
	#player.jump_count = 0

func exit()->void:
	pass
