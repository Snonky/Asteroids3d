extends PolarSpawner

onready var powerupScene = preload("res://Assets/Powerup.tscn")

signal powerup_spawned(powerup)
signal powerup_destroyed(powerup)

# Array of resources holding each powerup type's icon, model and function
export(Array, Resource) var powerup_types = []
export(float, 0, 10, .1) var box_rotation_speed = .3


func spawn_entity():
	var powerup = .spawn_entity()
	var type = powerup_types[rng.randi_range(0, powerup_types.size()-1)]
	
	powerup["type"] = type
	
	var translation = polar2cartesian(powerup["r"], powerup["th"])
	translation = Vector3(translation.x, 0, translation.y)
	var velocity = translation.normalized() * powerup["speed"]
	var rotation_axis = Vector3(
		rng.randf()-.5,
		rng.randf()-.5,
		rng.randf()-.5).normalized()
	var body = powerupScene.instance()
	add_child(body)
	body.translate(translation)
	body.setup(velocity, powerup, rotation_axis, box_rotation_speed)
	powerup["body"] = body
	
	emit_signal("powerup_spawned", powerup)
	
	
func destroy_entity(powerup, fx = false):
	var destroyed = .destroy_entity(powerup)
	if destroyed:
		if fx:
			powerup["body"].play_box_open_animation()
		else:
			powerup["body"].queue_free()
		emit_signal("powerup_destroyed", powerup)

