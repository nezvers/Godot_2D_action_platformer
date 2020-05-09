extends KinematicBody2D
class_name Player

onready var body:Node2D = $Body
onready var state_machine: = $"StateMachine"
onready var grnd1: = $"Body/Grnd1"
onready var grnd2: = $"Body/Grnd2"
onready var grnd3: = $"Body/Grnd3"
var RayGround:bool = false
var NoWeaponSprite: = preload("res://Assets/Characters/Adventurer.png")
var WeaponSprite: = preload("res://Assets/Characters/AdventurerWeapon.png")

var velocity:		= Vector2()
var speed:			= 0.0
var run_speed:		= 2.0 * 60.0
var crouch_speed:	= 0.7 * 60.0
var wall_jmp_speed	= 4.0 * 60.0
var slide_speed:	= 3.0 * 60.0
var acceleration:	= 10.0 * 60.0
var jump_speed:		= -5.0 * 60.0
var jump_release:	= jump_speed * 0.2
var gravity_speed:	= 17.0 * 60.0
var attack_gravity: = 5.0 * 60.0

var gravity:		= gravity_speed

var normal_fall:	= -jump_speed
var wall_fall:		= 1.0 * 60.0
var attack_fall:	= 2.0 * 60.0
var fall_limit:		= normal_fall

var direction:		= 0.0
var right:			= 0.0
var left:			= 0.0
var up:				= 0.0
var down:			= 0.0
var jump:			= false

var is_grounded:	= false
var solidcheck:	= 0
const SNAP:			= 4.0
const NO_SNAP:		= 0.0
var snap:			= Vector2.ZERO
var floor_angle:	= PI * 0.25

var is_jumping:		= false
var jump_count:int	= 0
var max_jumps:int	= 2
var jump_top_speed:	= 100.0
var last_wall:int	= 0

onready var timer:	= $"Timer"
var jump_buffer:	= 0.5 #0.16
var slide_time: 	= 0.3

var is_damaged:		= false
var damage_timer:	= 0.2

var has_sword: = false setget set_has_sword
var sword_is_active: = false setget set_sword_is_active

func _ready()->void:
	set_has_sword(has_sword)

func unhandled_input(event:InputEvent)->void:
	#Decoupling all input calls from physics_process - 
	if event.is_action_pressed("move_right") && right <= 0.01:
		right = event.get_action_strength("move_right")
		direction += right
	elif event.is_action_released("move_right"):
		direction -= right
		right = 0.0
	elif event.is_action_pressed("move_left") && left <= 0.01:
		left = event.get_action_strength("move_left")
		direction -= left
	elif event.is_action_released("move_left"):
		direction += left
		left = 0.0
	elif event.is_action_pressed("move_up") && up <= 0.01:
		up = event.get_action_strength("move_up")
	elif event.is_action_released("move_up"):
		up = 0.0
	elif event.is_action_pressed("move_down") && down <= 0.01:
		down = event.get_action_strength("move_down")
	elif event.is_action_released("move_down"):
		down = 0.0
	elif event.is_action_pressed("jump") && !jump:
		jump = true
	elif event.is_action_released("jump"):
		jump = false

func physics_process(delta:float)->void:
	velocity_logic(delta)
	gravity_logic(delta)
	collision_logic()
	ground_update_logic()

func velocity_logic(delta:float)->void:
	velocity = velocity.move_toward(Vector2(direction * speed, velocity.y), acceleration * delta)

func gravity_logic(delta:float)->void:
	if is_grounded:
		if is_jumping:              #landed the jump
			jump = false            #force release jump button
			is_jumping = false
			snap.y = SNAP
		elif jump && down < 0.01:                  #works also when re-pressed before ground
			velocity.y = jump_speed
			is_jumping = true
			is_grounded = false
			snap.y = NO_SNAP
	else:
		if is_jumping:
			if !jump:               #released jump button mid-air
				is_jumping = false
				if velocity.y < jump_release:
					velocity.y = jump_release
			else:
				velocity.y += gravity * delta
		else:
			velocity.y += gravity * delta
	velocity.y = min(velocity.y, fall_limit)

func collision_logic()->void:
	velocity = move_and_slide_with_snap(velocity, snap, Vector2.UP, true, 4, floor_angle, false)

func ground_update_logic()->void:
	RayGround_update()
	if is_grounded:
		if !is_on_floor() || !RayGround:          #lost the ground
			is_grounded = false
			snap.y = NO_SNAP
	else:
		if is_on_floor() && RayGround:           #just landed
			is_grounded = true
			jump_count = max_jumps
			snap.y = SNAP
			last_wall = 0

func RayGround_update()->void:
	grnd1.force_raycast_update()
	grnd2.force_raycast_update()
	grnd3.force_raycast_update()
	RayGround = grnd1.is_colliding() || grnd2.is_colliding() || grnd3.is_colliding()

func facing_direction()->void:
	if abs(direction) > 0.0:			#always assume floats can't be equal
		body.scale.x = sign(direction)

func set_is_damaged(value:bool)->void:
	if value != is_damaged:
		is_damaged = value

func damage(dir:float, dmg:float = 0.0)->void:
	if is_damaged:
		return
	set_is_damaged(true)
	if is_grounded:
		if dmg < 2:
			state_machine.transition_to("Damage", {dir = dir})
		else:
			state_machine.transition_to("Knock_down", {dir = dir})
	else:
		state_machine.transition_to("Knock_down", {dir = dir})

func set_has_sword(value: bool)->void:
	has_sword = value
	if has_sword:
		$Body/Sprite.texture = WeaponSprite
	else:
		$Body/Sprite.texture = NoWeaponSprite

func set_sword_is_active(value:bool)->void:
#	if !has_sword || value == has_sword:	#don't have sword or same state
#		return
	sword_is_active = value

func _on_CornerSpaceCheck_body_entered(body):
	solidcheck += 1

func _on_CornerSpaceCheck_body_exited(body):
	solidcheck -= 1
