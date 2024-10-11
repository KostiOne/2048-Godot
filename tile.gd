extends Node2D

var value = 2
var has_merged = false

@onready var label = $Sprite2D/Control/Label as Label
@onready var sprite = $Sprite2D as Sprite2D

func animate_spawn(has_delay):
	var tween = get_tree().create_tween()
	sprite.scale = Vector2(0.2, 0.2)
	var delay = 0.5 if has_delay else 0
	sprite.modulate.a = 0
	
	tween.parallel().tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_QUAD).set_delay(delay)
	tween.parallel().tween_property(sprite, "modulate",Color.WHITE, 0.2).set_trans(Tween.TRANS_QUAD).set_delay(delay)
	tween.parallel().tween_property(sprite, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_QUAD).set_delay(delay)

func animate_tile(newPos, should_free):
	var tween = get_tree().create_tween()
	tween.tween_property(self,"position", newPos, 0.5).set_trans(Tween.TRANS_QUAD)
	
	if should_free:
		sprite.z_index = 0
		
		tween.tween_callback(queue_free)

func animate_merge():
	sprite.z_index = 2;
	var tween = get_tree().create_tween()
	
	value *= 2
	#label.text = str(value)
	var bg = get_color_for_background(value)
	var fg = get_color_for_foreground(value)
	
	
	var delay: float = 0.1
	var time = 0.2
	tween.parallel().tween_property(sprite, "self_modulate", bg,time).set_delay(delay)
	tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), time).set_trans(Tween.TRANS_QUINT).set_delay(delay)
	tween.tween_property(label, "theme_override_colors/font_color", fg, time).set_trans(Tween.TRANS_QUINT).set_delay(delay)
	tween.tween_callback(update_label)
	tween.tween_property(sprite, "scale", Vector2(1, 1), time).set_trans(Tween.TRANS_QUINT).set_delay(delay)
	
	tween.tween_callback(_reset_z_index)

func update_label():
	label.text = str(value)
	
	var font_size = 36
	if value >= 1024:
		font_size = 20
	elif  value >= 128:
		font_size = 28
	
	#var tween = get_tree().create_tween()
	#tween.tween_property(sprite, "theme_override_font_sizes/font_size", font_size, 0.2)

func update_value(new_value):
	value = new_value
	update_label()

func _reset_z_index():
	sprite.z_index = 1

func get_color_for_background(v):
	if v == 4:
		return Color8(237,224,200,255)
	elif v == 8:
		return Color8(242,177,121,255)
	elif v == 16:
		return Color8(245,149,99,255)
	elif v == 32:
		return Color8(246,124,96,255)
	elif v == 64:
		return Color8(246,94,59,255)
	elif v == 128:
		return Color8(237,207,115,255)
	elif v == 256:
		return Color8(237,204,98,255)
	elif v == 512:
		return Color8(237,200,80,255)
	elif v == 1024:
		return Color8(237,197,63,255)
	elif v == 2048:
		return Color8(237,194,45,255)

func get_color_for_foreground(v):
	if v == 4:
		return Color8(119,110,101,255)
	else:
		return Color8(249,246,246,255)
