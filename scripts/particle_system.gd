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
