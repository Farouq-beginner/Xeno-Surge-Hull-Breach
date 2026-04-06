extends CharacterBody2D

# Kecepatan alien (dibuat lebih lambat dari player agar bisa dihindari)
const SPEED = 150.0 

var player_target = null

func _ready():
	# Saat alien muncul, dia akan mencari objek di grup "player"
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_target = players[0] # Mengunci target ke player pertama yang ditemukan

func _physics_process(delta):
	if player_target != null:
		var direction = global_position.direction_to(player_target.global_position)
		velocity = direction * SPEED
		look_at(player_target.global_position)
		
		# Cek tabrakan saat bergerak
		var collision = move_and_collide(velocity * delta)
		
		if collision:
			var collider = collision.get_collider()
			# Jika yang ditabrak adalah Player
			if collider.is_in_group("player"):
				collider.take_damage(1) # Kurangi darah 1 setiap frame sentuhan
