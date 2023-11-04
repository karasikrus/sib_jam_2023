extends Area2D
class_name ClockSector

signal time_period_started
signal time_period_ended

@export var normal_color: Color
@export var highlight_color: Color

func _ready():
	area_entered.connect(on_area_entered)
	area_exited.connect(on_area_exited)


func on_area_entered(area: Area2D):
	$Polygon2D.color = highlight_color
	time_period_started.emit()


func on_area_exited(area: Area2D):
	$Polygon2D.color = normal_color
	time_period_ended.emit()
