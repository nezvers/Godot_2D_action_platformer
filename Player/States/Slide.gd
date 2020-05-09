extends PlayerState

onready var headCollision: = $"../../Head"
onready var headCheck1: = $"../../Body/HeadCheck1"
onready var headCheck2: = $"../../Body/HeadCheck2"
onready var timer: = $"../../Timer"

var slide_time: 		= 0.3

var canStand:bool		= false
var timeout:			= false
var dir:				= 0.0

func unhandled_input(event:InputEvent)->void:
	player.unhandled_input(event)
	

func physics_process(delta:float)->void:
	canStand = !headCheck1.is_colliding() && !headCheck2.is_colliding()
	velocity_logic(delta)
	player.collision_logic()
	player.ground_update_logic()

func velocity_logic(delta:float)->void:
	player.velocity = Vector2(dir * player.speed, player.velocity.y)

func process(delta:float)->void:
	state_check()

func enter(msg:Dictionary = {})->void:
	player.speed = player.slide_speed
	player.jump = false
	animation.play("Slide")
	dir = sign(player.body.scale.x)
	headCollision.disabled = true
	headCheck1.enabled = true
	headCheck2.enabled = true
	timeout = false
	timer.connect("timeout", self, "timeout")
	timer.wait_time = player.slide_time
	timer.start()
	

func exit()->void:
	headCollision.disabled = false
	headCheck1.enabled = false
	headCheck2.enabled = false
	player.jump = false
	timer.disconnect("timeout", self, "timeout")

func state_check()->void:
	if player.is_grounded:
		if timeout:
			_state_machine.transition_to('Stand_up', {})
	else:
		player.timer.wait_time = player.jump_buffer
		player.timer.start()
		var y:float = player.velocity.y
		if abs(y) < player.jump_top_speed:
			_state_machine.transition_to('Jump_top', {})
		elif y > 0.0:
			_state_machine.transition_to('Jump_fall', {})
		elif y < 0.0:
			_state_machine.transition_to('Jump', {})

func timeout()->void:
	timeout = true
