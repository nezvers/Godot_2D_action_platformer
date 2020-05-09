extends PlayerState

onready var headCollision: = $"../../Head"
onready var headCheck1: = $"../../Body/HeadCheck1"
onready var headCheck2: = $"../../Body/HeadCheck2"
onready var timer: = $"../../Timer"

var canStand:bool		= false

func unhandled_input(event:InputEvent)->void:
	player.unhandled_input(event)

func physics_process(delta:float)->void:
	velocity_logic(delta)
	player.collision_logic()
	player.ground_update_logic()

func velocity_logic(delta:float)->void:
	player.velocity = player.velocity.move_toward(Vector2(0.0, player.velocity.y), player.acceleration * delta)

func process(delta:float)->void:
	state_check()

func state_check(anim:String = '')->void:
	headCheck1.force_raycast_update()
	headCheck2.force_raycast_update()
	canStand = !headCheck1.is_colliding() && !headCheck2.is_colliding()
	
	if player.is_grounded:
		if !anim.empty():
			if canStand:
				if player.jump:
					player.is_jumping = true
					player.velocity.y = player.jump_speed
					_state_machine.transition_to("Jump", {})
				elif abs(player.direction) < 0.01:
					if player.down < 0.01:
						_state_machine.transition_to("Idle", {})
					else:
						_state_machine.transition_to('Crouch', {})
				else:
					if player.down < 0.01:
						_state_machine.transition_to("Run", {})
					else:
						_state_machine.transition_to('Crouch_walk', {})
			else:
				if abs(player.direction) < 0.01:
					_state_machine.transition_to('Crouch', {})
				else:
					_state_machine.transition_to('Crouch_walk', {})
	else:
		if player.is_jumping:
			if player.jump:
				timer.stop()
				_state_machine.transition_to("Jump", {})
		else:
			var y:float = player.velocity.y
			if abs(y) < player.jump_top_speed:
				timer.stop()
				_state_machine.transition_to('Jump_top', {})
			elif y > 0.0:
				timer.stop()
				_state_machine.transition_to('Jump_fall', {})
			elif y < 0.0:
				timer.stop()
				_state_machine.transition_to('Jump', {})

func enter(msg:Dictionary = {})->void:
	animation.play("Stand_up")
	animation.connect("animation_finished", self, "state_check")
	headCollision.disabled = true
	headCheck1.enabled = true
	headCheck2.enabled = true

func exit(msg:Dictionary = {})->void:
	animation.disconnect("animation_finished", self, "state_check")
	headCollision.disabled = false
	headCheck1.enabled = false
	headCheck2.enabled = false
