extends Destructible

var velocity
var powerup
var rotation_axis
var rotation_speed


func setup(v, powerup_data, rot_axis, rot_speed):
	velocity = v
	powerup = powerup_data
	rotation_axis = rot_axis
	rotation_speed = rot_speed
	
func _physics_process(delta):
	var collision = move_and_collide(delta * velocity)
	if (collision):
		if(collision.collider is Projectile):
			collision.collider.queue_free()
			damage(collision.collider.damage)
			
func _process(delta):
	$container.rotate(rotation_axis, rotation_speed * delta)

func destroy():
	#get_parent().destroy_entity(powerup, true)
	play_box_open_animation()
	# Disable projectile collisions
	set_collision_mask_bit(1, false)

func play_box_open_animation():
	$container/BoxDissolveAnimation.play("ArmatureAction")


func _on_anim_finished(_anim):
	pass
