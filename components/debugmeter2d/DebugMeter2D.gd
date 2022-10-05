@tool
class_name DebugMeter2D
extends Control

@icon("DebugMeter2D.svg")

## Debug Meter 2D version 1.0
##
## A very simple debug meter that takes a float input and represents as the height of the meter.
## The meter accepts any value range, as long as `max_value` is a higher value than `min_value` (the other way around is not tested).
##
## The meter can be customized: range, colors and the placement of the baseline.
##
## The value passed to the meter will show below the meter.

@export_category("Bar")
## The highest value you expect to pass to the meter. It should be higher than the value set for min_value.
@export var max_value: float = 100

## The lowest value you expect to pass to the meter. It should be lower than the value set for min_value.
@export var min_value: float = 0

## The color you want to see when the passed value exceeds the expected range of the meter.
@export var range_exceeded_bar_color: Color = Color("d90031")

## The value of the meter before input. Should be within the range of the meter.
@export var initial_value: float = 100

## The color of the meter for when the value passed to the meter is more than zero.
@export var default_bar_color: Color = Color("00a43a")

@export_category("Baseline")

## Toggle to show or hide the baseline.
@export var show_base_line: bool = true

## The color of the meter below the baseline.
@export var bar_color_below_baseline: Color = Color("f4c221")

## The relative vertical position of the baseline: 0 is all the way down, 1 is all the way up. 
@export_range(0, 100) var relative_position_of_baseline: float = 0

## The color of the bar when it goes below the baseline.
@export var change_bar_color_below_baseline: bool = false

## Internal variable
@onready var _on_screen_bar_height: float = $Bar.size.y
@onready var _relative_unit: float = _on_screen_bar_height / (abs(max_value) + abs(min_value))
@onready var _actual_value: float = initial_value

var _center_offset: float
var baseline_screen_position: float = 0

func _ready() -> void:
	_setup()
	_move_baseline_as_needed()
	update_value(initial_value)


func _process(_delta) -> void:
	if !Engine.is_editor_hint():
		return
	_setup()
	_move_baseline_as_needed()
	update_value(initial_value)


## The API for the Meter. Call this with the float you want to see reflected by the meter.
## The new_value may exceed the range of the meter, which will cause the meter to change color (ref. range_exceeded_bar_color).
func update_value(new_value: float) -> void:
	_actual_value = new_value	
	_update_value_label()
	_update_bar()
	_update_bar_color()



# Handling Bar Value Updates
# --------------------------------------------------------------------------------------------------


func _setup() -> void:
	var range_of_bar = (max_value - min_value)
	_relative_unit = _on_screen_bar_height / range_of_bar
	if 0 > min_value && 0 < max_value:
		_center_offset = ((max_value - min_value) - abs(min_value)) * _relative_unit
	elif 0 >= max_value:
		_center_offset = 0
	else:
		_center_offset = _on_screen_bar_height


func _move_baseline_as_needed() -> void:
	$Baseline.position.y = _on_screen_bar_height - (_on_screen_bar_height * (relative_position_of_baseline / 100))


func _update_value_label() -> void:
	$Value.text = ("%.2f" % _actual_value)
	
	
func _update_bar():
	var bar_value_within_range = clamp(_actual_value, min_value, max_value)
	var screen_bar_height = abs(bar_value_within_range * _relative_unit)
	$Bar.size.y = screen_bar_height
	if bar_value_within_range < 0:
		# Fixed position below zero because bar grow downwards
		$Bar.position.y = _center_offset
	else:
		# Moving bar down to negate bar height
		$Bar.position.y = _center_offset - screen_bar_height


func _update_bar_color() -> void:
	if !change_bar_color_below_baseline:
		return
	if _actual_value > max_value || _actual_value < min_value:
		$Bar.color = range_exceeded_bar_color
	elif _actual_value < 0:
		$Bar.color = bar_color_below_baseline
	else:
		$Bar.color = default_bar_color
	
