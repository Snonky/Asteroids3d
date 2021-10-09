extends KinematicBody

var velocity
var powerup


func setup(v, powerup_data):
	velocity = v
	powerup = powerup_data
	
func _physics_process(delta):
	var collision = move_and_collide(delta * velocity)
	if (collision):
		powerup["type"].execute()
		get_parent().destroy_entity(powerup)
		destroy()
	
func destroy(_finished_animation = ""):
	queue_free()
