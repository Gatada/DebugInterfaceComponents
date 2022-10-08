extends Control

## Shows how the DebugMeter2D and DebugStateLabel2D can be used.
##
## The two meters and state labels are responding to the input values from a sinus curve.
## One label will highlight when a meter peaks, the other when the value reaches zero.
##
## The demo will show the duration of the highlighted state if not deliberately overwritten.

## Appends the delta to its value to demonstrate how the meter and labels works and looks like.

## Allows the debug meters to progress over time.
var _demo_duration_in_seconds: float = 0

## Toggle sound played when receiving event signals.
@export var _play_event_sounds: bool = true


func _process(delta: float) -> void:
	_update_subzero_debug_meter(sin(_demo_duration_in_seconds + 0.7))
	_update_symmetric_debug_meter(sin(_demo_duration_in_seconds + 0.3))
	_update_negative_range_debug_meter(sin(_demo_duration_in_seconds + 1))
	_update_zero_and_up_debug_meter(sin(_demo_duration_in_seconds + 2.9))
	_demo_duration_in_seconds += delta


func _update_subzero_debug_meter(input) -> void:
	# Meter range (max, min): 10, -5
	var value = ((input + 1) * -10) + 12.5 # Exceeding range to show overflow
	$SubzeroMeter.value(value)


func _update_symmetric_debug_meter(input) -> void:
	# Meter range (max, min): 0, -100
	var value = (input - 1) * 50
	$SymmetricMeter.value(value)
	

func _update_negative_range_debug_meter(input) -> void:
	# Meter ranges from (max, min): -50, -100
	var value = ((input - 1) * 25) - 50
	$NegativeRangeMeter.value(value)


func _update_zero_and_up_debug_meter(input) -> void:
	# Meter range (max, min): 100, 0.
	var value = (input + 1) * 50
	$ZeroAndUpMeter.value(value)


# Events
# --------------------------------------------------------------------------------------------------

func _on_input_exceeding_range() -> void:
	$ExceededLabel.highlighted = true
	if _play_event_sounds:
		$ExceedingRange.play()


func _on_input_reaching_target_value() -> void:
	$TargetLabel.highlighted = true
	if _play_event_sounds:
		$TargetReached.play()
