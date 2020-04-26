extends PlayerState

var hit: = false
var impulse: = Vector2.ZERO
var deacceleration: = 0.0
#Impulse strength
var spd1: = 1.0 * 60.0
#stopping speed
var dcc1: = 2.0 * 60.0

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
	player.velocity = player.velocity.move_toward(Vector2.ZERO, deacceleration * delta)

func gravity_logic(delta:float)->void:
	if !player.is_grounded:
		player.velocity.y += player.gravity * delta
	player.velocity.y = min(player.velocity.y, player.fall_limit)

func state_check(anim:String = '')->void:
	if !anim.empty():
		if player.is_grounded:
			if !anim.empty():
				player.facing_direction()
				animation.play("Attack2")
				if hit:
					player.sword_is_active = true
					_state_machine.transition_to('Attack', {})
				else:
					_state_machine.transition_to('Idle', {})
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
	impulse.x = imp
	deacceleration = dcc
	player.velocity.x = 0.0
	player.velocity += impulse

func enter(msg:Dictionary = {})->void:
	animation.play("Damage")
	player.body.scale.x = -msg.dir
	set_impulse(spd1 * msg.dir, dcc1)
	animation.connect("animation_finished", self, "state_check")

func exit()->void:
	hit = false
	animation.disconnect("animation_finished", self, "state_check")
	yield(get_tree().create_timer(player.damage_timer), "timeout")
	player.is_damaged = false
