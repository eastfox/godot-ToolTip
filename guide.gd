extends Node2D

func _on_touch_pressed() -> void:
	get_tree().change_scene_to_file("res://touch.tscn")

func _on_mouse_pressed() -> void:
	get_tree().change_scene_to_file("res://mouse.tscn")
