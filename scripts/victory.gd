extends Control

# Mengambil referensi ke node Label yang ada di DALAM ScoreFrame
@onready var score_label = $ScoreFrame/FinalScoreLabel 

func _ready():
	# Bersihkan sisa power-up di layar (praktik yang sangat bagus!)
	for item in get_tree().get_nodes_in_group("powerups"):
		item.queue_free()
		
	# Terapkan teks ke node LABEL, bukan ke TextureRect
	# Catatan: Pastikan Autoload Anda bernama 'GlobalData' sesuai kode Anda ini
	score_label.text = " " + str(GlobalData.final_score)

func _on_start_button_pressed():
	# Kembali ke menu utama (Pastikan path folder Anda benar)
	get_tree().change_scene_to_file("res://main_menu.tscn")
