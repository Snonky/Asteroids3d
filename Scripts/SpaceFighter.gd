extends Spatial

signal ship_movement(angle_delta, current_angle)

var direction = 0
var angular_velocity = 0
var maxSpeed = .003
var accelleration = .001
var decelleration = .002
var swipeWidth = 200.0

var tilt = 0
var maxTilt = .5

var facing_angle = 1.5*PI setget set_facing_angle, get_facing_angle

var fingerIndex = -1

var drag_start = Vector2(0,0)

	
func _physics_process(delta):
	move_process()


func _unhandled_input(event):
	if event is InputEventScreenDrag && event.index == fingerIndex:
		if event.speed.x > 1000.0:
			$shieldbash_mesh.play()
		elif event.speed.x < -1000.0:
			$shieldbash_mesh2.play()
		var relative = event.position - drag_start
		direction = clamp(relative.x / swipeWidth, -1, 1)
		if(abs(relative.x) > swipeWidth):
			drag_start.x += relative.x - swipeWidth * sign(relative.x)
	elif event is InputEventScreenTouch:
		if event.pressed && fingerIndex == -1:
			drag_start = event.position
			fingerIndex = event.index
		elif event.index == fingerIndex:
			direction = 0
			fingerIndex = -1

func move_process():
	if(direction != 0):
		angular_velocity = direction * min(maxSpeed, abs(angular_velocity) + accelleration)
	elif angular_velocity != 0:
		angular_velocity = sign(angular_velocity) * max(0, abs(angular_velocity) - decelleration)

	if(angular_velocity != 0):
		# Rotate around center of asteroid ring
		var relative_pos = $"../AsteroidSpawner".translation - translation
		global_translate(relative_pos)
		rotate_object_local(Vector3.UP, -angular_velocity)
		relative_pos = (-relative_pos).rotated(Vector3.UP, -angular_velocity)
		global_translate(relative_pos)
		
		set_facing_angle(facing_angle + angular_velocity)
		emit_signal("ship_movement", angular_velocity, facing_angle)
		
	if(angular_velocity != 0 or tilt != 0):
		rotate_ship(direction);
	
func rotate_ship(direction):
	var current = tilt;
	if(direction != 0):
		tilt -= direction * accelleration*100
		tilt = sign(tilt) * min(maxTilt * abs(angular_velocity/maxSpeed), abs(tilt))
	else:
		tilt = sign(tilt) * max(0, abs(tilt) - decelleration*40)
	
	$SpaceFighterBody.rotate(Vector3.FORWARD, tilt - current)
	
func set_facing_angle(new_angle):
	facing_angle = fposmod(new_angle, TAU)

func get_facing_angle():
	return facing_angle

