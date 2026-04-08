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
		# Beri damage 1 ke musuh
		if body.has_method("take_damage"):
			body.take_damage(1)
		
		queue_free() # Peluru hancur setelah menabrak
