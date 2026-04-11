extends Node2D

@onready var health_bar = $CanvasLayer/HealthBar
@onready var score_label = $CanvasLayer/ScoreLabel
@onready var notify_label = $CanvasLayer/NotifyLabel
@onready var player = $Player

# CONTOH CARA MENGHAPUS SEMUA POWER-UP SECARA MANUAL

var score = 0
var total_terminals = 3
var repaired_count = 0

func show_notification(text: String, text_color: Color = Color.WHITE):
	notify_label.text = text
	
	# Mengubah warna teks sesuai parameter, tapi set alpha (transparansi) ke 0 dulu
	notify_label.modulate = text_color
	notify_label.modulate.a = 0.0 
	
	# Membuat animasi muncul dan menghilang
	var tween = create_tween()
	tween.tween_property(notify_label, "modulate:a", 1.0, 0.2) # Muncul
	tween.tween_interval(1.5) # Tahan
	tween.tween_property(notify_label, "modulate:a", 0.0, 0.5) # Menghilang

func _process(delta):
	if player:
		health_bar.value = player.health
	score_label.text = "Score: " + str(score)

func add_score(amount):
	score += amount

# Fungsi baru untuk menangani perbaikan terminal
func terminal_repaired():
	repaired_count += 1
	print("Terminal diperbaiki! Total: ", repaired_count, "/", total_terminals)
	
	# Tambahkan bonus skor besar
	add_score(500) 
	
	if repaired_count >= total_terminals:
		win_game()

func win_game():
	for item in get_tree().get_nodes_in_group("powerups"):
		item.queue_free()

	
	GlobalData.final_score = score
	# Berpindah ke scene kemenangan
	get_tree().change_scene_to_file("res://scenes/victory.tscn")
