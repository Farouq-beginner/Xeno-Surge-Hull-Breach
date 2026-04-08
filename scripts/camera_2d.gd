extends Camera2D

# Seberapa cepat getaran menghilang (semakin besar angkanya, semakin cepat berhenti)
var shake_fade: float = 15.0

# Kekuatan getaran saat ini
var current_strength: float = 0.0

# Fungsi ini akan dipanggil dari script pemain
func apply_shake(strength: float):
	current_strength = strength

func _process(delta):
	if current_strength > 0:
		# Mengurangi kekuatan perlahan-lahan sampai menjadi 0
		current_strength = move_toward(current_strength, 0, shake_fade * delta)
		
		# Menghasilkan posisi acak untuk sumbu X dan Y
		var offset_x = randf_range(-1, 1) * current_strength
		var offset_y = randf_range(-1, 1) * current_strength
		
		# Menggeser kamera (properti bawaan Camera2D)
		offset = Vector2(offset_x, offset_y)
	else:
		# Pastikan kamera kembali ke tengah jika getaran sudah habis
		offset = Vector2.ZERO
