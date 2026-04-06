extends Area2D

@onready var progress_bar = $ProgressBar

var is_player_near = false
var is_repaired = false
var repair_time = 0.0
const MAX_REPAIR_TIME = 3.0 # Butuh 3 detik untuk memperbaiki

func _ready():
	progress_bar.value = 0
	progress_bar.hide() # Sembunyikan bar jika pemain tidak di dekatnya

func _process(delta):
	if is_repaired:
		return # Berhenti memproses jika sudah selesai
		
	if is_player_near:
		# Mengecek apakah tombol E DITAHAN (bukan hanya ditekan sekali)
		if Input.is_action_pressed("interact"):
			repair_time += delta # Menambah waktu berdasarkan *frame rate*
			progress_bar.value = repair_time
			
			if repair_time >= MAX_REPAIR_TIME:
				finish_repair()
		else:
			# Opsi: Jika dilepas, progress hilang (mulai dari 0 lagi)
			repair_time = 0.0
			progress_bar.value = repair_time

func finish_repair():
	is_repaired = true
	progress_bar.modulate = Color(0, 1, 0) # Mengubah warna bar menjadi Hijau
	
	# Memberi tahu Level Utama bahwa satu terminal sudah selesai
	var level = get_tree().current_scene
	if level.has_method("terminal_repaired"):
		level.terminal_repaired()

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
