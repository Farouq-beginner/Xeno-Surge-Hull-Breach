extends Node2D

# Memuat scene alien agar bisa di-spawn
var enemy_scene = preload("res://scenes/enemy.tscn")

func _on_timer_timeout():
	# 1. Buat instance alien baru
	var enemy = enemy_scene.instantiate()
	
	# 2. Atur posisi alien agar sama dengan posisi spawner ini
	enemy.global_position = global_position
	
	# 3. Masukkan ke dalam level utama (parent dari spawner ini)
	# Gunakan get_parent() agar alien tidak "menempel" pada spawner jika spawner bergerak
	get_parent().add_child(enemy)
