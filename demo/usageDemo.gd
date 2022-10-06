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

## Ensures the sound effect is finished playing before it repeats the sound.
var _meter_peaked_is_ready_to_play: bool = true

## Ensures the sound effect is finished playing before it repeats the sound.
var _zero_highlighted_is_ready_to_play: bool = true

## Toggle sound played when receiving event signals.
var preference_play_sounds: bool = false


func _process(delta: float) -> void:
	var input = sin(_demo_duration_in_seconds)
	_update_symmetric_debug_meter(input)
	_update_subzero_debug_meter(input) # Moving it along by PI for a more dynamic demo
	_demo_duration_in_seconds += delta
	

func _update_symmetric_debug_meter(input) -> void:
	var symmetric_input = input * 100
	$SymmetricDebugMeter.value(symmetric_input)
	
	var floored_symmetric_input = round(symmetric_input)
	update_zero_label(floored_symmetric_input)
	if floored_symmetric_input == 0:
		play_zero_highlighted()
	
	var did_peak = int(round(abs(symmetric_input))) == 100
	update_peaked_label(did_peak)
	if did_peak:
		play_meter_peaks()


func update_zero_label(input) -> void:
	if input == 0:
		$ZeroLabel.highlighted = true

		
func play_zero_highlighted() -> void:
		if preference_play_sounds && _zero_highlighted_is_ready_to_play:
			$ZeroHighlighted.play()
			_zero_highlighted_is_ready_to_play = false


func update_peaked_label(did_peak) -> void:
	if did_peak:
		$PeakedLabel.highlighted = true

func play_meter_peaks() -> void:
		if preference_play_sounds && _meter_peaked_is_ready_to_play:
			$MeterPeaked.play()
			_meter_peaked_is_ready_to_play = false


func _update_subzero_debug_meter(input) -> void:
	var ranged_input = ((input + 1) * -7.5) + 10
	$SubzeroDebugMeter.value(ranged_input)
	update_zero_label(ranged_input)
	
	var rounded_ranged_input = round(ranged_input)
	update_zero_label(rounded_ranged_input)
	if rounded_ranged_input == 0:
		play_zero_highlighted()
	
	var did_peak = int(round(rounded_ranged_input)) == -20
	update_peaked_label(did_peak)
	if did_peak:
		play_meter_peaks()



func _on_zero_highlighted_finished() -> void:
	_zero_highlighted_is_ready_to_play = true


func _on_meter_peaked_finished() -> void:
	_meter_peaked_is_ready_to_play = true
