extends PlayerState

func unhandled_input(event:InputEvent)->void:
	#doesn't matter for the state but need to track direction pressing
	player.unhandled_input(event)

func physics_process(delta:float)->void:
	velocity_logic(delta)
	gravity_logic(delta)
	player.collision_logic()
	player.ground_update_logic()

func velocity_logic(delta:float)->void:
	player.velocity = player.velocity.move_toward(Vector2.ZERO, player.acceleration * delta)

func gravity_logic(delta:float)->void:
	if !player.is_grounded:
		player.velocity.y += player.gravity * delta
	player.velocity.y = min(player.velocity.y, player.fall_limit)

func process(delta:float)->void:
	state_check()

func state_check(anim:String = '')->void:
	if !anim.empty():
		_state_machine.transition_to("Idle", {})
	elif player.is_grounded:
		if player.jump:
			player.velocity.y = player.jump_speed
			player.is_jumping = true
			player.is_grounded = false
			player.snap.y = player.NO_SNAP
			_state_machine.transition_to("Jump", {})
		elif abs(player.direction) > 0.01:
			_state_machine.transition_to("Run", {})
	else:
		_state_machine.transition_to("Jump_top", {})

func enter(msg:Dictionary = {})->void:
	player.sword_is_active = false
	animation.play("Sheath")
	animation.connect("animation_finished", self, "state_check")

func exit()->void:
	animation.disconnect("animation_finished", self, "state_check")
