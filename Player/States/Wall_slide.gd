extends PlayerState


onready var wallCheck1: = $"../../Body/WallCheck1"
onready var wallCheck2: = $"../../Body/WallCheck2"

var dir: = 0.0

func unhandled_input(event:InputEvent)->void:
	player.unhandled_input(event)

func physics_process(delta:float)->void:
	#force against the wall with override on direction
	velocity_logic(delta)
	gravity_logic(delta)
	player.collision_logic()
	player.ground_update_logic()


func velocity_logic(delta:float)->void:
	player.velocity.x += dir	#just some push against the wall

func gravity_logic(delta:float)->void:
	if !player.is_grounded:
		player.velocity.y += player.gravity * delta
	player.velocity.y = min(player.velocity.y, player.fall_limit)

func process(delte:float)->void:
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
			if abs(player.direction) > 0.01:
				player.velocity.x = sign(player.direction) * player.wall_jmp_speed
				_state_machine.transition_to("Jump_wall", {})
			else:
				_state_machine.transition_to("Jump", {})

func enter(msg:Dictionary = {})->void:
	animation.play("Wall_slide")
	dir = sign(player.body.scale.x)
	player.fall_limit = player.wall_fall
	player.jump = false
	player.last_wall = sign(dir)
	wallCheck1.enabled = true
	wallCheck2.enabled = true

func exit()->void:
	player.fall_limit = player.normal_fall
	wallCheck1.enabled = false
	wallCheck2.enabled = false
