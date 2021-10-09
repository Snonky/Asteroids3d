extends KinematicBody
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
		$Hitbox.disabled = true
		get_parent().destroy_entity(asteroid, true)

func destroy(_finished_animation):
	queue_free()
