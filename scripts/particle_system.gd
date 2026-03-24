extends Node2D

## Simple particle system for eat and death effects — Phase 3

const EAT_PARTICLE := preload("res://assets/sprites/particles/eat_particle.png")
const DEATH_PARTICLE := preload("res://assets/sprites/particles/death_explosion.png")

## Spawn eat particles at a world position
func spawn_eat_effect(world_pos: Vector2) -> void:
	const PARTICLE_COUNT := 10
	const DURATION := 0.4  # seconds
	const SPEED := 150.0
	const EAT_COLOR := Color("#4ade80")
	
	for i in range(PARTICLE_COUNT):
		var particle := Sprite2D.new()
		particle.texture = EAT_PARTICLE
		particle.centered = true
		particle.modulate = EAT_COLOR
		particle.position = world_pos
		add_child(particle)
		
		# Random direction outward
		var angle := (2.0 * PI * i) / PARTICLE_COUNT + randf() * 0.5
		var velocity := Vector2(cos(angle), sin(angle)) * SPEED
		
		# Animate particle
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", world_pos + velocity * DURATION, DURATION)
		tween.tween_property(particle, "modulate:a", 0.0, DURATION)
		tween.tween_property(particle, "scale", Vector2(0.2, 0.2), DURATION)
		tween.tween_callback(Callable(func():
			if is_instance_valid(particle):
				particle.queue_free()
		))

## Spawn shield break particles at a world position
func spawn_shield_break_effect(world_pos: Vector2) -> void:
	const PARTICLE_COUNT := 20
	const DURATION := 0.6
	const SPEED := 200.0
	const COLORS := [Color(0.4, 0.7, 1.0), Color(0.6, 0.85, 1.0), Color(0.27, 0.53, 1.0)]
	
	for i in range(PARTICLE_COUNT):
		var particle := Sprite2D.new()
		particle.texture = EAT_PARTICLE
		particle.centered = true
		particle.modulate = COLORS[randi() % COLORS.size()]
		particle.position = world_pos
		add_child(particle)
		
		var angle := randf() * 2.0 * PI
		var speed := SPEED * (0.4 + randf() * 0.6)
		var velocity := Vector2(cos(angle), sin(angle)) * speed
		
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", world_pos + velocity * DURATION, DURATION)
		tween.tween_property(particle, "modulate:a", 0.0, DURATION)
		tween.tween_property(particle, "scale", Vector2(0.3, 0.3), DURATION)
		tween.tween_callback(Callable(func():
			if is_instance_valid(particle):
				particle.queue_free()
		))

## Spawn slow trail particle at a world position
func spawn_slow_trail(world_pos: Vector2) -> void:
	var particle := Sprite2D.new()
	particle.texture = EAT_PARTICLE
	particle.centered = true
	particle.modulate = Color(0.3, 0.7, 1.0, 0.6)
	particle.position = world_pos
	particle.scale = Vector2(0.5, 0.5)
	add_child(particle)
	
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(particle, "modulate:a", 0.0, 0.4)
	tween.tween_property(particle, "scale", Vector2(0.1, 0.1), 0.4)
	tween.tween_callback(Callable(func():
		if is_instance_valid(particle):
			particle.queue_free()
	))

## Spawn shrink/compression particle at a world position
func spawn_shrink_effect(world_pos: Vector2) -> void:
	const PARTICLE_COUNT := 15
	const DURATION := 0.5
	const SPEED := 100.0
	const COLORS := [Color(0.67, 0.27, 1.0), Color(0.85, 0.5, 1.0), Color(0.55, 0.15, 0.85)]
	
	for i in range(PARTICLE_COUNT):
		var particle := Sprite2D.new()
		particle.texture = EAT_PARTICLE
		particle.centered = true
		particle.modulate = COLORS[randi() % COLORS.size()]
		particle.position = world_pos
		add_child(particle)
		
		# Implode inward then fade
		var angle := randf() * 2.0 * PI
		var velocity := Vector2(cos(angle), sin(angle)) * SPEED
		
		var tween := create_tween()
		tween.set_parallel(true)
		# First move outward slightly
		tween.tween_property(particle, "position", world_pos + velocity * 0.15, 0.15)
		# Then implode
		tween.tween_property(particle, "position", world_pos, 0.15 + DURATION * 0.5)
		tween.tween_property(particle, "modulate:a", 0.0, DURATION)
		tween.tween_property(particle, "scale", Vector2(0.2, 0.2), DURATION)
		tween.tween_callback(Callable(func():
			if is_instance_valid(particle):
				particle.queue_free()
		))

## Spawn death explosion particles at a world position
func spawn_death_effect(world_pos: Vector2) -> void:
	const PARTICLE_COUNT := 25
	const DURATION := 1.0  # seconds
	const SPEED := 250.0
	const COLORS := [Color("#ef4444"), Color("#f97316"), Color("#eab308"), Color("#fbbf24")]
	
	for i in range(PARTICLE_COUNT):
		var particle := Sprite2D.new()
		particle.texture = DEATH_PARTICLE
		particle.centered = true
		particle.modulate = COLORS[randi() % COLORS.size()]
		particle.position = world_pos
		particle.scale = Vector2(1.5, 1.5)
		add_child(particle)
		
		# Random direction outward
		var angle := randf() * 2.0 * PI
		var speed := SPEED * (0.5 + randf() * 0.5)
		var velocity := Vector2(cos(angle), sin(angle)) * speed
		
		# Animate particle
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", world_pos + velocity * DURATION, DURATION)
		tween.tween_property(particle, "modulate:a", 0.0, DURATION)
		tween.tween_property(particle, "scale", Vector2(0.3, 0.3), DURATION)
		tween.tween_callback(Callable(func():
			if is_instance_valid(particle):
				particle.queue_free()
		))
