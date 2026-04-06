extends Area2D

var speed = 800.0

func _physics_process(delta):
	position += transform.x * speed * delta

func _ready():
	await get_tree().create_timer(2.0).timeout
	queue_free()

# Fungsi baru yang dibuat otomatis oleh Godot dari Signal
func _on_body_entered(body):
	if body.is_in_group("enemy"):
		# Mencari node MainLevel untuk memanggil fungsi add_score
		# Kita asumsikan MainLevel adalah root dari scene yang sedang berjalan
		var level = get_tree().current_scene
		if level.has_method("add_score"):
			level.add_score(10) # Memberi 10 poin per alien
		
		body.queue_free() # Alien hancur
		queue_free()      # Peluru hancur
