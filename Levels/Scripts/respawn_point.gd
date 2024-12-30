extends Node3D

@onready var point = $Point
@onready var area_3d = $Area3D

func _ready() -> void:
	area_3d.body_entered.connect(_respawn)

func _respawn(body: Node3D) -> void:
	if body is Player:
		print("meow")
		body.global_transform = point.global_transform
