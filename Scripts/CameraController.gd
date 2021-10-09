extends Spatial

func _on_SpaceFighter_ship_movement(angle, _v):
	# Rotate around center of asteroid ring
	var relative_pos = $"../AsteroidSpawner".translation - translation
	global_translate(relative_pos)
	rotate_object_local(Vector3.UP, -angle)
	relative_pos = (-relative_pos).rotated(Vector3.UP, -angle)
	global_translate(relative_pos)
