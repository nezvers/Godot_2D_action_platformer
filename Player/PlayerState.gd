extends State
class_name PlayerState
# Base type for the player's state classes. Contains boilerplate code to get
# autocompletion and type hints.

onready var player: = owner
onready var animation:AnimationPlayer = owner.get_node('AnimationPlayer')

var next_state: = {}
