class_name SprintingComponent
extends Node3D

var is_sprinting = false
@export var max_sprinting_speed = 17.5
@export var sprinting_accel = 2.0
@onready var sprinting_drag = float(sprinting_accel) / max_sprinting_speed

@onready var player_mover = get_parent()

func _process(delta):
	# go to sprint from walk or crouch
	if Input.is_action_pressed("sprint") and Input.is_action_pressed("move_forward"):
		enable_sprinting()
	
	# go from sprint to walk or crouch
	if Input.is_action_just_released("sprint") or Input.is_action_just_released("move_forward"):
		disable_sprinting()

func enable_sprinting():
	is_sprinting = true

func disable_sprinting():
	is_sprinting = false
