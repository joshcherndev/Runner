extends Node3D

@export var linear_speed = 1.0
@export var follow_path = true

@onready var area_3d: Area3D = $Area3D
@onready var path_follow_3d = $Path3D/PathFollow3D

func _ready() -> void:
	area_3d.body_entered.connect(end_run)

func _process(delta):
	if follow_path:
		update_progress(delta)

func end_run(body: Node3D):
	if body is Player:
		get_tree().reload_current_scene()

func update_progress(delta: float):
	path_follow_3d.progress_ratio += delta * linear_speed
