extends Node2D
class_name Items

var player
var msg: = {}

func _ready()->void:
	set_process(false)

func _on_Area2D_body_entered(body):
	player = body
	set_process(true)

func _process(delta:float)->void:
	#wait when player is grounded to trigger Item state
	if player.is_grounded:
		trigger()
		set_process(false)
		#Disable area2d for animation
		$Area2D.monitorable = false
		$Area2D.monitoring = false

func trigger()->void:
	pass

