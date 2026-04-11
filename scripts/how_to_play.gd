extends Control

# Bersihkan powerup yang mungkin nyangkut (opsional tapi aman)
func _ready():
	for item in get_tree().get_nodes_in_group("powerups"):
		item.queue_free()

func _on_back_button_pressed():
	# Ganti "Button" dengan nama node tombol Anda jika berbeda
	get_tree().change_scene_to_file("res://main_menu.tscn")
