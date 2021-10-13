extends Destructible
class_name AsteroidBody

var velocity = Vector3.ZERO
var asteroid

func setup(v, asteroid_data):
	velocity = v
	asteroid = asteroid_data

func _physics_process(delta):
	var collision = move_and_collide(delta * velocity)
	if(collision):
		if(collision.collider is Projectile):
			collision.collider.queue_free()
			damage(collision.collider.damage)
		else:
			destroy()

func destroy():
	$Hitbox.disabled = true
	get_parent().destroy_entity(asteroid, true)
	$cut/AnimationPlayer.play("Cut")
	

func _on_anim_finished(_anim):
	queue_free()
