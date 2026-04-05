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
		# Menghitung arah dari alien ke player
		var direction = global_position.direction_to(player_target.global_position)
		
		# Mengatur kecepatan berdasarkan arah
		velocity = direction * SPEED
		
		# Membuat alien selalu menghadap ke player
		look_at(player_target.global_position)
		
		# Bergerak!
		move_and_slide()
