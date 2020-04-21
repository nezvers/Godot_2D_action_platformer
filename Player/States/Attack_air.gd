extends PlayerState

var hit: = false
var impulse: = Vector2.ZERO
var deacceleration: = 0.0
#Impulse strength
var att_spd1: = 0.5 * 60.0
var att_spd2: = 1.0 * 60.0
#stopping speed
var att_dcc1: = 8.0 * 60.0
var att_dcc2: = 6.0 * 60.0

func unhandled_input(event:InputEvent)->void:
	#doesn't matter for the state but need to track direction pressing
	if event.is_action_pressed("attack"):
		hit = true
	else:
		player.unhandled_input(event)

func physics_process(delta:float)->void:
	velocity_logic(delta)
	gravity_logic(delta)
	player.collision_logic()
	player.ground_update_logic()

func velocity_logic(delta:float)->void:
	player.velocity = player.velocity.move_toward(Vector2(0.0, player.velocity.y), deacceleration * delta)

func gravity_logic(delta:float)->void:
	if !player.is_grounded:
		player.velocity.y += player.gravity * delta
	player.velocity.y = min(player.velocity.y, player.fall_limit)

func state_check(anim:String = '')->void:
	if !anim.empty():
		if player.is_grounded:
			_state_machine.transition_to('Idle', {})
		else:
			if hit:
				if anim == "Attack1_air" && hit:
					player.facing_direction()
					set_impulse(att_spd2, att_dcc2)
					hit = false
					animation.play("Attack2_air")
				elif anim == "Attack2_air" && hit:
					player.facing_direction()
					hit = false
					_state_machine.transition_to('Attack_air_slam', {})
			else:
				player.timer.wait_time = player.jump_buffer
				player.timer.start()
				var y:float = player.velocity.y
				if abs(y) < player.jump_top_speed:
					_state_machine.transition_to('Jump_top', {})
				elif y > 0.0:
					_state_machine.transition_to('Fall', {})
				elif y < 0.0:
					_state_machine.transition_to('Jump', {})

func set_impulse(imp:float, dcc:float)->void:
	impulse.x = imp * player.body.scale.x
	impulse.y = player.jump_speed * 0.2
	deacceleration = dcc

func add_impulse()->void:
	player.velocity = impulse

func enter(msg:Dictionary = {})->void:
	player.velocity.y = 0.0
	player.gravity = player.attack_gravity
	player.fall_limit = player.attack_fall
	animation.play("Attack1_air")
	set_impulse(att_spd1, att_dcc1)
	animation.connect("animation_finished", self, "state_check")

func exit()->void:
	player.gravity = player.gravity_speed
	player.fall_limit = player.normal_fall
	animation.disconnect("animation_finished", self, "state_check")
