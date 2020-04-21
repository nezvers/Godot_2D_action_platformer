extends Items

func trigger()->void:
	player.state_machine.transition_to("Item", {item = self, msg = {has_sword = true, sword_is_active = true}})

