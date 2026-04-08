extends CPUParticles2D

func _ready():
	# Memulai emisi partikel
	emitting = true
	$ExplosionSFX.play()
	# Menunggu (await) sampai partikel selesai ber-emisi (Lifetime habis)
	await finished
	# Menghapus scene partikel ini sendiri dari game
	queue_free()
