extends PlayerState


onready var wallCheck1: = $"../../Body/WallCheck1"
onready var wallCheck2: = $"../../Body/WallCheck2"

var dir: = 0.0
var inputDir: = 0.0

func unhandled_input(event:InputEvent)->void:
	#track actual input direction
	if event.is_action_pressed("move_right") && player.right <= 0.01:
		player.right = event.get_action_strength("move_right")
		inputDir += player.right
	elif event.is_action_released("move_right"):
		inputDir -= player.right
		player.right = 0.0
	elif event.is_action_pressed("move_left") && player.left <= 0.01:
		player.left = - event.get_action_strength("move_left")
		inputDir += player.left
	elif event.is_action_released("move_left"):
		inputDir -= player.left
		player.left = 0.0
	else:
		player.unhandled_input(event)

func physics_process(delta:float)->void:
	#force against the wall with override on direction
	player.physics_process(delta)
	state_check()

func state_check()->void:
	wallCheck1.force_raycast_update()
	wallCheck2.force_raycast_update()
	var on_wall:bool = wallCheck1.is_colliding() && wallCheck2.is_colliding()
	
	if player.is_grounded:
		if abs(player.direction) < 0.01:
			_state_machine.transition_to('Idle', {})
		else:
			_state_machine.transition_to('Run', {})
	else:
		if !on_wall || player.down > 0.01:
			player.timer.wait_time = player.jump_buffer
			player.timer.start()
			_state_machine.transition_to("Jump_top", {})
		if player.jump:
			player.jump = true
			player.is_jumping = true
			player.velocity.y = player.jump_speed
			if abs(inputDir) > 0.01:
				player.velocity.x = sign(inputDir) * player.wall_jmp_speed
				_state_machine.transition_to("Jump_wall", {})
			else:
				_state_machine.transition_to("Jump", {})

func enter(msg:Dictionary = {})->void:
	animation.play("Wall_slide")
	dir = sign(player.body.scale.x)
	player.fall_limit = player.wall_fall
	inputDir = player.direction
	player.direction = dir
	player.jump = false
	player.last_wall = sign(dir)
	wallCheck1.enabled = true
	wallCheck2.enabled = true

func exit()->void:
	player.direction = inputDir
	player.fall_limit = player.normal_fall
	wallCheck1.enabled = false
	wallCheck2.enabled = false
