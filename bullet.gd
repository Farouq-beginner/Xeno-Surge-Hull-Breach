extends Area2D

var speed = 800.0

func _physics_process(delta):
	position += transform.x * speed * delta

func _ready():
	await get_tree().create_timer(2.0).timeout
	queue_free()

# Fungsi baru yang dibuat otomatis oleh Godot dari Signal
func _on_body_entered(body):
	# Mengecek apakah benda yang ditabrak (body) masuk dalam grup "enemy"
	if body.is_in_group("enemy"):
		body.queue_free() # Menghancurkan musuh (alien)
		queue_free()      # Menghancurkan peluru ini sendiri
