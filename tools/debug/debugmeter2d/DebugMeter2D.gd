@tool
class_name DebugMeter2D
extends Control

@icon("DebugMeter2D.svg")

# Debug Meter 2D version 1.0
#
# A very simple debug meter that takes a float input and represents as the height of the meter.
# The meter accepts any value range, as long as `max_value` is a higher value than `min_value` (the other way around is not tested).
#
# The meter can be customized: range, colors and the placement of the baseline.
#
# The value passed to the meter will show below the meter.

signal input_reached_baseline()

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

## The bar height is used to find the relative position of the baseline.
@onready var _on_screen_bar_height: float = $Bar.size.y

## Screen size relative unit to vertically position the bar.
@onready var _relative_unit: float = _on_screen_bar_height / (abs(max_value) + abs(min_value))

## The input variable as it is shown below the bar.
@onready var _actual_value: float = initial_value

## The offset of center.
var _center_offset: float

## The vertical screen position of the baseline relative to screen size.
var baseline_screen_position: float = 0

## The actual value represented by the baseline
var _baseline_value: float = 0
var baseline_value: float:
	set(new_value):
		if new_value != _baseline_value:
			_baseline_value = new_value
			_update_value_label(new_value)
	get:
		return _baseline_value

func _ready() -> void:
	_setup()
	_update_baseline_as_needed(initial_value)
	value(initial_value)

func _process(_delta) -> void:
	if Engine.is_editor_hint():
		_setup()
		_update_baseline_as_needed(initial_value)
		value(initial_value)


## The API for the Meter. Call this with the float you want to see reflected by the meter.
## The new_value may exceed the range of the meter, which will cause the meter to change color (ref. range_exceeded_bar_color).
func value(new_value: float) -> void:
	if _actual_value != new_value:
		_actual_value = new_value
		_update_value_label(_actual_value)
	_update_bar()
	_update_bar_color()
	_emit_signal_if_input_matches_baseline(_actual_value)



# Handling Bar Value Updates
# --------------------------------------------------------------------------------------------------


func _setup() -> void:
	assert(max_value > min_value)
	var range_of_bar = (max_value - min_value)
	_relative_unit = _on_screen_bar_height / range_of_bar
	if 0 > min_value && 0 < max_value:
		# Value range is from a positive to a negative number: bar grows out from zero
		_center_offset = ((max_value - min_value) - abs(min_value)) * _relative_unit
	elif 0 >= max_value:
		# Value range from zero and lower: bar grows downwards
		_center_offset = 0
	else:
		# Value range is above zero: bar grows upwards
		_center_offset = _on_screen_bar_height


func _update_baseline_as_needed(input: float) -> void:
	$Baseline.position.y = (_on_screen_bar_height * (relative_position_of_baseline / 100))
	if 0 > min_value && 0 < max_value:
		baseline_value = max_value - ((abs(max_value) + abs(min_value)) * (relative_position_of_baseline / 100))
	elif 0 >= max_value:
		# Value range from zero and lower: bar grows downwards
		baseline_value = max_value - ((max_value - min_value) * (relative_position_of_baseline / 100))
	else:
		# Value range is above zero: bar grows upwards
		baseline_value = max_value - ((abs(max_value) + abs(min_value)) * (relative_position_of_baseline / 100))


func _update_value_label(value: float) -> void:
	$Value.text = ("%.2f" % value)
	
	
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
	if _actual_value > max_value || _actual_value < min_value:
		$Bar.color = range_exceeded_bar_color
	elif change_bar_color_below_baseline && _actual_value < baseline_value:
		$Bar.color = bar_color_below_baseline
	else:
		$Bar.color = default_bar_color
		
	

func _emit_signal_if_input_matches_baseline(input: float) -> void:
	if input == baseline_value:
		emit_signal("input_reached_baseline")
