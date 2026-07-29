extends CharacterBody2D

const SPEED: int = 100
const KNOCKBACK_FORCE: int = 100
const STOP_DISTANCE = 40

var is_alive = true
var target = null
var health: int = 100

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D



func _physics_process(delta: float) -> void:
	if is_alive and target:
		_attack(delta)

func _attack(_delta: float) -> void:
	var distance = global_position.distance_to(target.global_position)
	print("distance: ", distance, " velocity: ", velocity)
	if distance > STOP_DISTANCE:
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * SPEED 
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	animated_sprite_2d.play("attack")

func take_damage(damage: int, attacker_position: Vector2) -> void:
	health -= damage
	print(health)
	
	if health <= 0:
		_die()
	else:
		# Knockback
		var knockback_direction = (position - attacker_position).normalized()
		var target_position = position + knockback_direction * KNOCKBACK_FORCE
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "position", target_position, 0.5)
		

func _die() -> void:
	is_alive = false
	animated_sprite_2d.play("die")
	
	# disable collision
	$CollisionShape2D.set_deferred("disabled", true)
	$Sight/CollisionShape2D.set_deferred("disabled", true)
	
func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print(target)
		target = body


func _on_sight_body_exited(body: Node2D) -> void:
		if body.name == "Player" and is_alive:
			target = null
			animated_sprite_2d.play("idle")
