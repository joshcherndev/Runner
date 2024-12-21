class_name CrouchComponent
extends Node3D

@export var max_crouching_speed = 5.0
@export var crouching_accel = 2.0
@onready var crouching_drag = crouching_accel / max_crouching_speed
@onready var crouching = false

func _process(delta):
	if Input.is_action_pressed("crouch"):
		crouching = true
	
	if Input.is_action_just_released("crouch"):
		crouching = false

func is_crouching():
	return crouching
