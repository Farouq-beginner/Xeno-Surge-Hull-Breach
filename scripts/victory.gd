extends Control

func _ready():
	# Set teks label skor akhir
	$ScoreLabel.text = "Final Score: " + str(GlobalData.final_score)

func _on_button_pressed():
	# Kembali ke menu utama
	get_tree().change_scene_to_file("res://main_menu.tscn")
