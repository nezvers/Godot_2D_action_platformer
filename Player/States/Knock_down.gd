extends PlayerState

signal landed

var knock_down_speed:	= 2.0 * 60.0
var stopping_speed:	= 3.0 * 60.0

var dir: = 0.0
var is_landed: = false

func unhandled_input(event:InputEvent)->void:
	#doesn't matter for the state but need to track direction pressing
	player.unhandled_input(event)

func physics_process(delta:float)->void:
	velocity_logic(delta)
	gravity_logic(delta)
	player.collision_logic()
	player.ground_update_logic()
	var tmp = is_landed
	is_landed = player.is_grounded
	if is_landed and !tmp:
		emit_signal("landed")

func velocity_logic(delta:float)->void:
	player.velocity = player.velocity.move_toward(Vector2.ZERO, stopping_speed * delta)

func gravity_logic(delta:float)->void:
	if !player.is_grounded:
		player.velocity.y += player.gravity * delta
	player.velocity.y = min(player.velocity.y, player.fall_limit)

func state_check(anim:String = '')->void:
	if anim == "Knock_down_pt1":
		if !player.is_grounded:
			yield(self, "landed")
		animation.play("Knock_down_pt2")
	elif anim == "Knock_down_pt2":
		if !player.is_grounded:
			yield(self, "landed")
		animation.play("Knock_down_pt3")
	elif anim == "Knock_down_pt3":
		if !player.is_grounded:
			yield(self, "landed")
		_state_machine.transition_to("Get_up", {})

func enter(msg:Dictionary = {})->void:
	animation.play("Knock_down_pt1")
	dir = msg.dir
	player.body.scale.x = -dir
	player.velocity.x = dir * knock_down_speed
	is_landed = player.is_grounded
	animation.connect("animation_finished", self, "state_check")

func exit()->void:
	animation.disconnect("animation_finished", self, "state_check")
