extends PlayerState

onready var headCollision: = $"../../Head"
onready var headCheck1: = $"../../Body/HeadCheck1"
onready var headCheck2: = $"../../Body/HeadCheck2"

var canStand:bool		= false
var slide:				= false
var jump:				= false

func unhandled_input(event:InputEvent)->void:
	if event.is_action_pressed("jump") && !jump:
		jump = true
	elif event.is_action_released("jump"):
		jump = false
	else:
		player.unhandled_input(event)

func physics_process(delta:float)->void:
	slide = player.jump
	canStand = !headCheck1.is_colliding() && !headCheck2.is_colliding()
	player.jump = false
	player.physics_process(delta)

func process(delta:float)->void:
	player.facing_direction()
	state_check()

func state_check()->void:
	headCheck1.force_raycast_update()
	headCheck2.force_raycast_update()
	canStand = !headCheck1.is_colliding() && !headCheck2.is_colliding()
	
	if player.is_grounded:
		if !canStand || player.down > 0.01:
			if jump:
				_state_machine.transition_to("Slide", {})
			elif abs(player.direction) < 0.01:
				_state_machine.transition_to("Crouch", {})
		else:
			if abs(player.direction) > 0.01:
				_state_machine.transition_to('Run', {})
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

func enter(msg:Dictionary = {})->void:
	player.speed = player.crouch_speed
	animation.play("Crouch_walk")
	headCollision.disabled = true
	headCheck1.enabled = true
	headCheck2.enabled = true

func exit()->void:
	headCollision.disabled = false
	headCheck1.enabled = false
	headCheck2.enabled = false
	jump = false
