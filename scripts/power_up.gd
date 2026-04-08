extends Area2D

# Mendefinisikan tipe power-up
enum Type {HEALTH, SPREAD_SHOT}
@export var current_type: Type = Type.HEALTH

@onready var sprite = $Sprite2D

func _ready():
	# Mengubah warna visual berdasarkan tipe (sebagai placeholder)
	if current_type == Type.HEALTH:
		sprite.modulate = Color(0, 1, 0) # Hijau untuk Medkit
	else:
		sprite.modulate = Color(1, 1, 0) # Kuning untuk Overdrive

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Memberikan item ke player melalui fungsi khusus
		body.collect_powerup(current_type)
		queue_free() # Item menghilang setelah diambil


func _on_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
