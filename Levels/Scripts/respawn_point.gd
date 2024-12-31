class_name RespawnPoint
extends Node3D

@onready var point = $Point
@onready var out_of_bounds_area_3d = $OutOfBoundsArea3D
@onready var checkpoint_area_3d = $CheckpointArea3D

signal respawn_point_set
signal player_out_of_bounds

func _ready() -> void:
	out_of_bounds_area_3d.body_entered.connect(_respawn)
	checkpoint_area_3d.body_entered.connect(_set_respawn_point)

func _set_respawn_point(body: Node3D) -> void:
	if body is Player:
		respawn_point_set.emit()

func _respawn(body: Node3D) -> void:
	if body is Player:
		player_out_of_bounds.emit()
