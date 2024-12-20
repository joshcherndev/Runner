extends Node3D

@export var time_offset = 0.1

@onready var children = get_children()
@onready var time_offset_accum = 0.0

func _ready():
	for child in children:
		if child is MovingTerrain:
			child.time_offset = time_offset_accum
			time_offset_accum += time_offset
