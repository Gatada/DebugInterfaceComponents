@tool
class_name DebugStateMeter2D
extends Control

@icon("DebugStateLabel2D.svg")

## Debug State Label 2D version 1.0
##
## A very simple customzable debug label with a highlight state that can be toggled on and off.
## When the label is highlighted, the background turns to the customized color.

@export var _is_highlighted: bool = false
@export var _caption: String = "Caption"
@export var _caption_color: Color = Color(1, 1, 1, 1)
@export var _backdrop_color: Color = Color(0, 0, 0, 0.30)
@export var _backdrop_color_highlighted: Color = Color(0, 0.57, 0.84)

var state_duration: float = 0
var state_retention: float = 0.07


func _ready() -> void:
	$Caption.set("theme_override_font_sizes/font_size", 22.0)
	_update_caption(_caption)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_update_caption(_caption)
	if _is_highlighted:
		# $Caption.add_theme_color_override("font_color", _caption_color_highlighted)
		_update_backdrop_color(_backdrop_color_highlighted)
		if !Engine.is_editor_hint():
			_reset_highlight_if_needed(delta)
	else:
		# $Caption.remove_theme_color_override("font_color")
		_update_backdrop_color(_backdrop_color)


var highlighted: bool:
	set(new_value):
		_is_highlighted = new_value
		state_duration = 0
	get:
		return _is_highlighted


# Helpers
# --------------------------------------------------------------------------------------------------


func _update_caption(new_string: String) -> void:
	_caption = new_string
	$Caption.text = _caption
	#$Caption.add_theme_color_override("font_color", _caption_color)
	$Caption.set("theme_override_colors/font_color", _caption_color)


func _update_backdrop_color(new_color: Color) -> void:
	$Backdrop.color = new_color


func _reset_highlight_if_needed(delta: float) -> void:
		state_duration += delta
		if state_duration > state_retention:
			_is_highlighted = false
			state_duration = 0
