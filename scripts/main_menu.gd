extends Control

func _on_start_button_pressed():
	# Berpindah ke scene level utama saat tombol diklik
	get_tree().change_scene_to_file("res://scenes/main_level.tscn")


func _on_tutorial_button_pressed(): # Sesuaikan nama fungsi dengan nama yang Anda hubungkan
	get_tree().change_scene_to_file("res://scenes/how_to_play.tscn")
