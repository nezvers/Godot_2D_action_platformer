extends PlayerState

onready var cornerGrab: = owner.get_node("CornerGrab")
onready var wallCheck1: = owner.get_node("Body/WallCheck1")
onready var wallCheck2: = owner.get_node("Body/WallCheck2")

var jump_top_threshold = 100.0

func unhandled_input(event:InputEvent)->void:
	if event.is_action_pressed("attack"):
		if player.has_sword:
			_state_machine.transition_to("Attack_air", {})
			player.sword_is_active = true
	else:
		player.unhandled_input(event)

func physics_process(delta:float)->void:
	if player.solidcheck == 0 && player.down <= 0.01:	#place is free for corner collision shape
		cornerGrab.disabled = false
		cornerGrab.position.x = player.direction	#because can't child to body so we shift position
	player.physics_process(delta)
	cornerGrab.disabled = true

func process(delta:float)->void:
	player.facing_direction()

func state_check()->bool:
	if player.is_grounded:
		if abs(player.direction) < 0.01:
			_state_machine.transition_to('Idle')
		else:
			_state_machine.transition_to('Run')
	elif player.is_on_floor() && player.down < 0.01:
		if player.is_on_wall():
			_state_machine.transition_to('Hang')
	else:	#not grounded
		if player.velocity.y >= 0.0 && sign(player.direction) == sign(player.body.scale.x) && sign(player.direction) != sign(player.last_wall) && player.is_on_wall():
			wallCheck1.enabled = true
			wallCheck2.enabled = true
			wallCheck1.force_raycast_update()
			wallCheck2.force_raycast_update()
			if wallCheck1.is_colliding() && wallCheck2.is_colliding():
				_state_machine.transition_to('Wall_slide')
			wallCheck1.enabled = false
			wallCheck2.enabled = false
		else:
			if (player.jump && !player.is_jumping) && (player.timer.time_left > 0.0 || player.jump_count > 0):
				if player.timer.time_left > 0.0:					#Coyote time
					player.velocity.y = player.jump_speed
					player.is_jumping = true
					player.timer.stop()
					print(_state_machine.current_state)
					_state_machine.transition_to("Jump")
				else:												#Doublejump
					player.velocity.y = player.jump_speed
					player.is_jumping = true
					player.jump_count -= 1
					_state_machine.transition_to("Jump_double")
			else:
				return true
	return false
#				var y:float = player.velocity.y
#				if abs(y) < jump_top_threshold:
#					_state_machine.transition_to('Jump_top')
#				elif y < jump_top_threshold:
#					_state_machine.transition_to('Jump')
#				elif y > jump_top_threshold:
#					_state_machine.transition_to('Jump_fall')

func enter(msg:Dictionary = {})->void:
	player.speed = player.run_speed
	animation.play("Jump_simple")

func exit()->void:
	pass
