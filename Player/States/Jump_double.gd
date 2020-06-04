extends PlayerState

func unhandled_input(event:InputEvent)->void:
	parent.unhandled_input(event)

func physics_process(delta:float)->void:
	parent.physics_process(delta)

func process(delta:float)->void:
	parent.process(delta)
	state_check()

func state_check(anim:String = '')->void:
	if	!parent.state_check():
		return
	
	if !anim.empty():
		var y:float = player.velocity.y
		if abs(y) < parent.jump_top_threshold:
			_state_machine.transition_to('Jump_top', {})
		elif y > 0.0:
			_state_machine.transition_to('Jump_fall', {})
		else:
			_state_machine.transition_to('Jump', {})

func enter(msg:Dictionary = {})->void:
	player.speed = player.run_speed
	animation.play("Jump_double")
	animation.connect("animation_finished", self, "state_check")

func exit()->void:
	animation.disconnect("animation_finished", self, "state_check")
