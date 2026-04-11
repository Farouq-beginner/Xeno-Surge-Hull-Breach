extends Node2D

var enemy_scene = preload("res://scenes/enemy.tscn")
var tank_scene = preload("res://scenes/tank_enemy.tscn")

func _on_timer_timeout():
	var enemy
	
	# Menggunakan probabilitas/acak (Random)
	# randf() menghasilkan angka acak dari 0.0 sampai 1.0
	if randf() < 0.20:
		# 20% peluang untuk memunculkan Tank
		enemy = tank_scene.instantiate()
	else:
		# 80% peluang memunculkan alien biasa
		enemy = enemy_scene.instantiate()
		
	enemy.global_position = global_position
	get_parent().add_child(enemy)
