extends State
class_name PlayerState
# Base type for the player's state classes. Contains boilerplate code to get
# autocompletion and type hints.

onready var animation:AnimationPlayer = $"../../AnimationPlayer"
onready var player: = owner

var next_state: = {}
