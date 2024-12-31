class_name Level
extends Node3D

@onready var player = $Player
@onready var respawn_points = $RespawnPoints
var current_respawn_point = null

func _ready() -> void:
	for child in respawn_points.get_children():
		if child is RespawnPoint:
			child.respawn_point_set.connect(_set_new_respawn_point.bind(child))
			child.player_out_of_bounds.connect(_respawn_player_at_respawn_point)

func _set_new_respawn_point(new_respawn_point: RespawnPoint) -> void:
	if current_respawn_point != new_respawn_point:
		current_respawn_point = new_respawn_point

func _respawn_player_at_respawn_point() -> void:
	player.global_transform = current_respawn_point.point.global_transform
