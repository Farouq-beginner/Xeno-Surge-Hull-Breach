extends Control

func _on_button_pressed():
	# Berpindah ke scene level utama saat tombol diklik
	get_tree().change_scene_to_file("res://scenes/main_level.tscn")
