class_name SprintingComponent
extends Node3D

@export var max_sprinting_speed = 16.0
@export var sprinting_accel = 2.0
@onready var sprinting_drag = sprinting_accel / max_sprinting_speed
@onready var sprinting = false
var debug = false
func _process(delta):
	if debug:
		# go to sprint from walk or crouch
		if Input.is_action_pressed("sprint") and Input.is_action_pressed("move_forward"):
			sprinting = true
		
		# go from sprint to walk or crouch
		if Input.is_action_just_released("sprint") or Input.is_action_just_released("move_forward"):
			sprinting = false

func is_sprinting():
	return sprinting
