@tool
class_name DebugMeter2D
extends Control

@icon("DebugMeter2D.svg")

# Debug Meter 2D version 1.0
#
# A very simple debug meter that takes a float input and represents as the height of the meter.
# The meter accepts any value range, as long as `max_value` is a higher value than `min_value` (the other way around is not tested).
#
# The meter can be customized: range, colors and the placement of the target value line.
#
# The value passed to the meter will show below the meter.

signal input_reached_target_value()
signal input_exceeds_range()

@export_category("Bar")

@export var emit_signals: bool = true

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

@export_category("Target Value")

## Toggle to show or hide the target value line.
@export var show_target_line: bool = true

## The color of the meter below the target value line.
@export var bar_color_below_baseline: Color = Color("f4c221")

## The relative vertical position of the target value line: 0 is all the way down, 1 is all the way up. 
@export_range(0, 100) var relative_position_of_target_line: float = 0

## The color of the bar when it goes below the target value line.
@export var change_bar_color_below_target_line: bool = false

## The bar height is used to find the relative position of the target value line.
@onready var _on_screen_bar_height: float = self.size.y - $Value.size.y

## Screen size relative unit to vertically position the bar.
@onready var _relative_unit: float = _on_screen_bar_height / (abs(max_value) + abs(min_value))

## The input variable as it is shown below the bar.
@onready var _actual_value: float = initial_value

## Used to center the bar when zero is within the range of the meter.
var _center_offset: float

## The actual value represented by the target value line
var _target_line_value: float = 0


func _ready() -> void:
	_setup()
	_update_target_value_line_as_needed(initial_value)
	if show_target_line:
		$Targetvalue.show()
	else:
		$Targetvalue.hide()


func _process(_delta) -> void:
	if Engine.is_editor_hint():
		_setup()
		_update_target_value_line_as_needed(initial_value)
		value(initial_value)
		if show_target_line:
			$Targetvalue.show()
		else:
			$Targetvalue.hide()
		


## The API for the Meter. Call this with the float you want to see reflected by the meter.
## The new_value may exceed the range of the meter, which will cause the meter to change color (ref. range_exceeded_bar_color).
func value(new_value: float) -> void:
	if _actual_value != new_value:
		_actual_value = new_value
		_update_value_label(_actual_value)
		_update_bar()
		_update_bar_color()


# Handling Bar Value Updates
# --------------------------------------------------------------------------------------------------


func _setup() -> void:
	assert(max_value > min_value)
	_on_screen_bar_height = self.size.y - $Value.size.y
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


func _update_target_value_line_as_needed(input: float) -> void:
	$Targetvalue.position.y = (_on_screen_bar_height * (relative_position_of_target_line / 100))
	var new_value: float
	if 0 >= min_value && 0 < max_value:
		new_value = max_value - ((abs(max_value) + abs(min_value)) * (relative_position_of_target_line / 100))
	else:
		# Both values are not neatly 
		new_value = max_value - (abs(abs(max_value) - abs(min_value)) * (relative_position_of_target_line / 100))
	if new_value != _target_line_value:
			_target_line_value = new_value
			_update_value_label(_target_line_value)


func _update_value_label(value: float) -> void:
	$Value.text = ("%.2f" % value)
	
	
func _update_bar():
	var bar_value_within_range = clampf(_actual_value, min_value, max_value)	
	if max_value < 0:
		$Bar.size.y = (max_value - bar_value_within_range) * _relative_unit
		$Bar.position.y = 0
	else:
		$Bar.size.y = abs(bar_value_within_range * _relative_unit)
		if bar_value_within_range < 0:
			# Fixed position below zero because bar grow downwards			
			$Bar.position.y = _center_offset
		else:
			# Moving bar down to negate bar height
			$Bar.position.y = _center_offset - $Bar.size.y


func _update_bar_color() -> void:
	if _actual_value > max_value || _actual_value < min_value:
		$Bar.color = range_exceeded_bar_color
		emit_signal_for_exceeded_range()
	elif change_bar_color_below_target_line && _actual_value < _target_line_value:
		const is_below_value_line = true
		check_reached_status_of_targetline(is_below_value_line)
		$Bar.color = bar_color_below_baseline
	else:
		const is_below_value_line = false
		check_reached_status_of_targetline(is_below_value_line)
		$Bar.color = default_bar_color


func check_reached_status_of_targetline(is_below_target_line: bool) -> void:
	if !emit_signals:
		return
	if is_below_target_line && $Bar.color != bar_color_below_baseline:
		emit_signal("input_reached_target_value")
	elif !is_below_target_line && $Bar.color == bar_color_below_baseline:
		emit_signal("input_reached_target_value")


func emit_signal_for_exceeded_range() -> void:
	if !emit_signals:
		return
	emit_signal("input_exceeds_range")
