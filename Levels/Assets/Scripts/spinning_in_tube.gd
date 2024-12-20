extends Node3D

@export var spin_speed = 1.0

func _process(delta):
	rotation_degrees.y += spin_speed
