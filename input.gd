extends Node2D

signal swipe(Vector2)

var blocked = true
var has_swiperd = false
var touch_threshold = 100
var touch_start = Vector2(0,0)

func connect_block_signal() -> void:
	get_parent().get_node("grid").connect("input_block", _on_input_blocked)

func _on_input_blocked(new_value):
	blocked = new_value

func _input(event: InputEvent) -> void:
	
	if event is InputEventScreenTouch:
		var touch = event as InputEventScreenTouch
		if touch.is_pressed():
			touch_start = touch.position
		if touch.is_released():
			########################print("touch RElease")
			has_swiperd = false
	elif  event is InputEventScreenDrag and not has_swiperd:
		var touch = event as InputEventScreenDrag
		var touch_end = touch.position
		var delta = touch_end - touch_start
		
		if blocked:
			return
		
		
		if abs(delta.x) > abs(delta.y):
			if delta.x > touch_threshold:
				#Right
				emit_signal("swipe", Vector2.RIGHT)
				has_swiperd = true
			elif  delta.x < -touch_threshold:
				#Left
				emit_signal("swipe", Vector2.LEFT)
				has_swiperd = true
		else:
			if delta.y > touch_threshold:
				#Down
				emit_signal("swipe", Vector2.DOWN)
				has_swiperd = true
			elif delta.y < -touch_threshold:
				#Up
				emit_signal("swipe", Vector2.UP)
				has_swiperd = true
