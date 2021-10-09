extends KinematicBody
class_name Projectile

export(Curve) var velocityCurve : Curve
export(float, 0.001, 30, .1) var lifetime = 1.0

var direction
var travel_time = 0.0
var fired = false

func fire(dir):
	direction = dir
	fired = true

func _physics_process(delta):
	if !fired: return
	var relative_lifetime = travel_time / lifetime
	var velocity = velocityCurve.interpolate_baked(relative_lifetime)
	move_and_collide(direction * velocity * delta)
	travel_time += delta
	if(travel_time > lifetime):
		free()
	
	
