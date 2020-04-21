extends PlayerState

onready var corner: = $"../../Body/CornerSpaceCheck"
onready var cornerGrab: = $"../../CornerGrab"
onready var grnd1: = $"../../Body/Grnd1"
onready var grnd2: = $"../../Body/Grnd2"
onready var grnd3: = $"../../Body/Grnd3"
onready var wallCheck1: = $"../../Body/WallCheck1"
onready var wallCheck2: = $"../../Body/WallCheck2"

var rayGround:bool
var jump_top_threshold = 100.0

func unhandled_input(event:InputEvent)->void:
	player.unhandled_input(event)

func physics_process(delta:float)->void:
	if player.cornercheck == 0 && player.down <= 0.01:	#place is free for corner collision shape
		cornerGrab.disabled = false
		cornerGrab.position.x = player.direction	#because can't child to body so we shift position
	player.physics_process(delta)
	grnd1.force_raycast_update()
	grnd2.force_raycast_update()
	grnd3.force_raycast_update()
	rayGround = grnd1.is_colliding() || grnd2.is_colliding() || grnd3.is_colliding()
	cornerGrab.disabled = true

func process(delta:float)->void:
	player.facing_direction()
	state_check()

func enter(msg:Dictionary = {})->void:
	player.speed = player.run_speed
	animation.play("Jump_simple")
	corner.monitorable = true
	corner.monitoring = true
	grnd1.enabled = true
	grnd2.enabled = true
	grnd3.enabled = true

func exit()->void:
	corner.monitorable = false
	corner.monitoring = false
	grnd1.enabled = false
	grnd2.enabled = false
	grnd3.enabled = false

func state_check()->void:
	var grounded:bool = player.is_grounded
	if grounded && rayGround:
		if abs(player.direction) < 0.01:
			_state_machine.transition_to('Idle', {})
		else:
			_state_machine.transition_to('Run', {})
	elif !rayGround && grounded && player.down < 0.01:
		if player.is_on_wall():
			_state_machine.transition_to('Hang', {})
	else:	#not grounded
		if (player.jump && !player.is_jumping) && (player.timer.time_left > 0.0 || player.jump_count > 0):
			if player.timer.time_left > 0.0:					#Coyote time
				player.velocity.y = player.jump_speed
				player.is_jumping = true
				player.timer.stop()
				_state_machine.transition_to("Jump", {})
			else:												#Doublejump
				player.velocity.y = player.jump_speed
				player.is_jumping = true
				player.jump_count -= 1
				_state_machine.transition_to("Jump_double", {})
		else:
			var y:float = player.velocity.y
			if abs(y) < jump_top_threshold:
				_state_machine.transition_to('Jump_top', {})
			elif y > 0.0:
				_state_machine.transition_to('Fall', {})
