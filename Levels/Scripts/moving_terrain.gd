class_name MovingTerrain
extends Node3D

@export var linear_speed = 1.0
@export var follow_path = true
@export var ping_pong = true
@export var ease = true
@export var ease_speed = 1.0
@export var time_offset = 0.0
var at_end = false
var x = 0.0

@onready var path_follow_3d = $Path3D/PathFollow3D

func _process(delta):
	if follow_path:
		update_progress(delta)

func update_progress(delta: float):
	if ping_pong:
		if is_equal_approx(path_follow_3d.progress_ratio, 1.0):
			at_end = true
		elif is_equal_approx(path_follow_3d.progress_ratio, 0.0):
			at_end = false
		
		if ease:
			path_follow_3d.progress_ratio = 0.5 * sin(x + time_offset) + 0.5
			x += delta * ease_speed
		else:
			if !at_end:
				path_follow_3d.progress_ratio += delta * linear_speed
			else:
				path_follow_3d.progress_ratio -= delta * linear_speed
	else:
		path_follow_3d.progress_ratio += delta * linear_speed
