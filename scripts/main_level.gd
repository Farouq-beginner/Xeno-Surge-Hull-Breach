extends Node2D

# --- Referensi UI ---
@onready var health_bar = $CanvasLayer/HealthBar
@onready var score_label = $CanvasLayer/ScoreLabel
@onready var notify_label = $CanvasLayer/NotifyLabel
@onready var overheat_bar = $CanvasLayer/OverheatBar # Tambahan untuk bar senjata

# --- Referensi Node ---
@onready var player = $Player
@onready var tilemap = $TileMap # Pastikan nama node TileMap Anda sesuai

# --- Variabel Level ---
var score = 0
var total_terminals = 3
var repaired_count = 0

func _ready():
	# 1. Mengatur batas pandangan kamera agar tidak keluar map
	set_camera_limits()
	
	# 2. Reset skor saat level baru dimulai
	score = 0
	score_label.text = "Score: " + str(score)

func _process(delta):
	# Memperbarui UI secara real-time setiap frame
	if player != null:
		# Update Darah
		health_bar.value = player.health
		
		# Update Panas Senjata (Overheat Bar)
		if overheat_bar != null:
			overheat_bar.value = player.heat
			
			# Jika senjata macet, ubah bar menjadi merah
			if player.is_overheated:
				overheat_bar.modulate = Color(1.0, 0.0, 0.0) # Merah
			else:
				overheat_bar.modulate = Color(1.0, 1.0, 1.0) # Normal / Putih

# Fungsi untuk menghitung dan menerapkan batas kamera secara dinamis
func set_camera_limits():
	if not tilemap or not player.has_node("Camera2D"):
		return
		
	var camera = player.get_node("Camera2D")
	var map_rect = tilemap.get_used_rect()
	var tile_size = tilemap.tile_set.tile_size
	
	# Mengubah koordinat grid menjadi piksel
	var limit_left = map_rect.position.x * tile_size.x
	var limit_right = (map_rect.position.x + map_rect.size.x) * tile_size.x
	var limit_top = map_rect.position.y * tile_size.y
	var limit_bottom = (map_rect.position.y + map_rect.size.y) * tile_size.y
	
	camera.limit_left = limit_left
	camera.limit_right = limit_right
	camera.limit_top = limit_top
	camera.limit_bottom = limit_bottom

func show_notification(text: String, text_color: Color = Color.WHITE):
	notify_label.text = text
	notify_label.modulate = text_color
	notify_label.modulate.a = 0.0 
	
	# Membuat animasi teks muncul dan menghilang
	var tween = create_tween()
	tween.tween_property(notify_label, "modulate:a", 1.0, 0.2) 
	tween.tween_interval(1.5) 
	tween.tween_property(notify_label, "modulate:a", 0.0, 0.5) 

func add_score(amount):
	score += amount
	score_label.text = "Score: " + str(score)

# Menangani perbaikan terminal reaktor
func terminal_repaired():
	repaired_count += 1
	print("Terminal diperbaiki! Total: ", repaired_count, "/", total_terminals)
	
	# Tampilkan Notifikasi di layar
	show_notification("TERMINAL REPAIRED: " + str(repaired_count) + "/" + str(total_terminals), Color(0.0, 1.0, 1.0))
	
	# Tambahkan bonus skor besar
	add_score(500) 
	
	if repaired_count >= total_terminals:
		win_game()

func win_game():
	# 1. Bersihkan sisa power-up di peta
	for item in get_tree().get_nodes_in_group("powerups"):
		item.queue_free()

	# 2. Simpan skor ke GlobalData agar bisa dibaca layar Victory
	GlobalData.final_score = score
	
	# 3. Jeda dramatis 1 detik sebelum pindah scene
	await get_tree().create_timer(1.0).timeout 
	
	# 4. Berpindah ke scene kemenangan
	get_tree().change_scene_to_file("res://scenes/victory.tscn")
