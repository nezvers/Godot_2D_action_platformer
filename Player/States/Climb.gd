extends PlayerState

export (Vector2) var climb: = Vector2.ZERO setget set_climb

onready var headCollision: = $"../../Head"
onready var headCheck1: = $"../../Body/HeadCheck1"
onready var headCheck2: = $"../../Body/HeadCheck2"

var init_position: = Vector2.ZERO
var dir: = 0.0
var ready: = false

func _ready()->void:
	ready = true

func set_climb(value:Vector2)->void:
	if ready:
		climb = value
		player.position = init_position + climb * Vector2(dir, 1.0)

func unhandled_input(event:InputEvent)->void:
	#doesn't matter for the state but need to track direction pressing
	player.unhandled_input(event)


func state_check(anim:String = '')->void:
	headCheck1.force_raycast_update()
	headCheck2.force_raycast_update()
	var canStand = !headCheck1.is_colliding() && !headCheck2.is_colliding()
	
	if !canStand || player.down > 0.01:
		if abs(player.direction) > 0.0:
			_state_machine.transition_to("Crouch_walk")
		else:
			
			_state_machine.transition_to("Crouch")
	else:
		if abs(player.direction) > 0.0:
			_state_machine.transition_to("Run", {})
		else:
			_state_machine.transition_to("Idle", {})

func enter(msg:Dictionary = {})->void:
	animation.play("Climb")
	init_position = player.position
	dir = msg.dir
	climb = Vector2.ZERO
	headCollision.disabled = true
	headCheck1.enabled = true
	headCheck2.enabled = true
	animation.connect("animation_finished", self, "state_check")

func exit()->void:
	headCollision.disabled = false
	headCheck1.enabled = false
	headCheck2.enabled = false
	animation.disconnect("animation_finished", self, "state_check")
