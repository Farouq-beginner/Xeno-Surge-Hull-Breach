extends Control

func _on_start_button_pressed():
	# Mengembalikan pemain ke layar judul utama
	get_tree().change_scene_to_file("res://main_menu.tscn")
