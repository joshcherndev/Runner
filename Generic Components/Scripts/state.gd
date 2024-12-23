class_name State
extends Node

@export var animation_name: String

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var animations: AnimationPlayer
var move_component
var parent: CharacterBody3D

func enter() -> void:
	animations.play(animation_name)

func exit() -> void:
	pass

func process_input(event: InputEvent) -> State:
	return null

func process_frame(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	return null

func get_movement_input() -> Vector2:
	return move_component.get_movement_direction()

func get_jump() -> bool:
	return move_component.wants_jump()
