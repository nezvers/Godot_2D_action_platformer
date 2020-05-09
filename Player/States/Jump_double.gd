extends PlayerState

onready var corner: = $"../../Body/CornerSpaceCheck"
onready var cornerGrab: = $"../../CornerGrab"
onready var wallCheck1: = $"../../Body/WallCheck1"
onready var wallCheck2: = $"../../Body/WallCheck2"

var rayGround:bool
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
	state_check()

func state_check(anim:String = '')->void:
	if player.is_grounded:
		if abs(player.direction) < 0.01:
			_state_machine.transition_to('Idle', {})
		else:
			_state_machine.transition_to('Run', {})
	elif player.is_on_floor() && player.down < 0.01:
		if player.is_on_wall():
			_state_machine.transition_to('Hang', {})
	else:	#not grounded
		if player.velocity.y >= 0.0 && sign(player.direction) == sign(player.body.scale.x) && sign(player.direction) != sign(player.last_wall) && player.is_on_wall():
			wallCheck1.enabled = true
			wallCheck2.enabled = true
			wallCheck1.force_raycast_update()
			wallCheck2.force_raycast_update()
			if wallCheck1.is_colliding() && wallCheck2.is_colliding():
				_state_machine.transition_to('Wall_slide', {})
			wallCheck1.enabled = false
			wallCheck2.enabled = false
		elif (player.jump && !player.is_jumping) && player.jump_count > 0:
			player.velocity.y = player.jump_speed
			player.is_jumping = true
			player.jump_count -= 1
			animation.stop()
			_state_machine.transition_to("Jump_double", {})
		elif !anim.empty():
			var y:float = player.velocity.y
			if abs(y) < jump_top_threshold:
				_state_machine.transition_to('Jump_top', {})
			elif y > 0.0:
				_state_machine.transition_to('Jump_fall', {})
			else:
				_state_machine.transition_to('Jump', {})

func enter(msg:Dictionary = {})->void:
	player.speed = player.run_speed
	animation.play("Jump_double")
	animation.connect("animation_finished", self, "state_check")
	corner.monitorable = true
	corner.monitoring = true

func exit()->void:
	animation.disconnect("animation_finished", self, "state_check")
	corner.monitorable = false
	corner.monitoring = false
