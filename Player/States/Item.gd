extends PlayerState

onready var ItemParent: = $"../../Body/ItemParent"

var item
var properties: = {}

func unhandled_input(event:InputEvent)->void:
	#doesn't matter for the state but need to track direction pressing
	player.unhandled_input(event)

func physics_process(delta:float)->void:
	velocity_logic(delta)
	gravity_logic(delta)
	player.collision_logic()
	player.ground_update_logic()

func velocity_logic(delta:float)->void:
	player.velocity = player.velocity.move_toward(Vector2.ZERO, player.acceleration * delta)

func gravity_logic(delta:float)->void:
	if !player.is_grounded:
		player.velocity.y += player.gravity * delta
	player.velocity.y = min(player.velocity.y, player.fall_limit)

func state_check(anim:String = '')->void:
	if !anim.empty():
		_state_machine.transition_to("Idle", {})

func enter(msg:Dictionary = {})->void:
	animation.play("Item")
	animation.connect("animation_finished", self, "state_check")
	properties = msg.msg
	item = msg.item
	item.get_parent().remove_child(item)
	item.position = Vector2.ZERO
	ItemParent.add_child(item)

func exit()->void:
	animation.disconnect("animation_finished", self, "state_check")
	item.queue_free()
	for key in properties:
		player.call("set", key, properties[key])
