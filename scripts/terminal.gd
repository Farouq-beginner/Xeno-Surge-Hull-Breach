extends Area2D

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var reactor_core: Sprite2D = $ReactorCore

# Frame data untuk animasi reactor core
var frames: Array[Rect2i] = [
	Rect2i(7, 164, 53, 76),
	Rect2i(75, 164, 53, 76),
	Rect2i(142, 164, 53, 76),
	Rect2i(210, 164, 53, 76)
]

var is_player_near = false
var is_repaired = false
var repair_time = 0.0
const MAX_REPAIR_TIME = 3.0 # Butuh 3 detik untuk memperbaiki

func _ready() -> void:
	progress_bar.value = 0
	progress_bar.hide() # Sembunyikan bar jika pemain tidak di dekatnya
	# Pastikan ReactorCore menggunakan texture dengan region enabled
	if reactor_core:
		reactor_core.region_enabled = true
		reactor_core.region_rect = frames[0]

func _process(delta: float) -> void:
	if is_repaired:
		return # Berhenti memproses jika sudah selesai
		
	if is_player_near:
		# Mengecek apakah tombol E DITAHAN (bukan hanya ditekan sekali)
		if Input.is_action_pressed("interact"):
			repair_time += delta # Menambah waktu berdasarkan *frame rate*
			progress_bar.value = repair_time
			
			# Update animasi reactor core sesuai dengan progress
			update_reactor_animation()
			
			if repair_time >= MAX_REPAIR_TIME:
				finish_repair()
		else:
			# Opsi: Jika dilepas, progress hilang (mulai dari 0 lagi)
			repair_time = 0.0
			progress_bar.value = repair_time
			update_reactor_animation()

func finish_repair() -> void:
	is_repaired = true
	progress_bar.modulate = Color(0, 1, 0) # Mengubah warna bar menjadi Hijau
	progress_bar.hide()
	
	# Animasi berhenti di frame terakhir (frame paling terang = penuh terisi)
	if reactor_core:
		reactor_core.region_rect = frames[frames.size() - 1]
	
	# Memberi tahu Level Utama bahwa satu terminal sudah selesai
	var level = get_tree().current_scene
	if level.has_method("terminal_repaired"):
		level.terminal_repaired()

func update_reactor_animation() -> void:
	"""Update frame animasi reactor core sesuai dengan progress bar"""
	if not reactor_core or frames.is_empty():
		return
	
	# Hitung frame index berdasarkan progress (0 hingga frames.size() - 1)
	var progress_ratio: float = repair_time / MAX_REPAIR_TIME
	progress_ratio = clamp(progress_ratio, 0.0, 1.0)
	
	var frame_index: int = int(progress_ratio * (frames.size() - 1))
	frame_index = clamp(frame_index, 0, frames.size() - 1)
	
	# Update frame sprite
	reactor_core.region_rect = frames[frame_index]

func _on_body_entered(body):
	if body.is_in_group("player") and not is_repaired:
		is_player_near = true
		progress_bar.show()

func _on_body_exited(body):
	if body.is_in_group("player"):
		is_player_near = false
		# Reset progress jika pemain kabur sebelum selesai
		if not is_repaired:
			repair_time = 0.0
			progress_bar.value = 0
			progress_bar.hide()
