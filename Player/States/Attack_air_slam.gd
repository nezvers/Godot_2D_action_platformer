extends PlayerState

var slam_speed: = 10.0 * 60.0
var slam_acceleration: = 25.0 * 60.0

func unhandled_input(event:InputEvent)->void:
	#doesn't matter for the state but need to track direction pressing
	player.unhandled_input(event)

func physics_process(delta:float)->void:
	velocity_logic(delta)
	player.collision_logic()
	player.ground_update_logic()

func velocity_logic(delta:float)->void:
	player.velocity = player.velocity.move_toward(Vector2(0.0, slam_speed), slam_acceleration * delta)

func process(delta:float)->void:
	state_check()

func state_check(anim:String = '')->void:
	if anim == "Attack3_air":
		animation.play("Attack3_air_loop")
	elif anim == "Attack3_air_end":
		_state_machine.transition_to('Idle', {})
	elif player.is_grounded && animation.current_animation != "Attack3_air_end":
			animation.play("Attack3_air_end")

func enter(msg:Dictionary = {})->void:
	player.velocity = Vector2.ZERO
	animation.play("Attack3_air")
	animation.connect("animation_finished", self, "state_check")

func exit()->void:
	animation.disconnect("animation_finished", self, "state_check")
