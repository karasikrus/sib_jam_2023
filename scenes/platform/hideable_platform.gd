extends StaticBody2D
class_name HideablePlatform

@export var active_color: Color
@export var hidden_color: Color
@export var clock_sector: ClockSector

@onready var collision_shape_2d = $CollisionShape2D
@onready var polygon_2d = $Polygon2D


func _ready():
	clock_sector.time_period_started.connect(show_platform)
	clock_sector.time_period_ended.connect(hide_platform)


func hide_platform():
	print("hide")
	collision_shape_2d.set_deferred("disabled", true)
	polygon_2d.color = hidden_color
	


func show_platform():
	print("show")
	collision_shape_2d.set_deferred("disabled", false)
	polygon_2d.color = active_color
