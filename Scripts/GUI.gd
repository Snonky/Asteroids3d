extends Control

onready var markerScene = preload("res://Assets/CompassMarker.tscn") 

func _on_SpaceFighter_ship_movement(angle_delta, view_angle):
	var compassMat = $HeadBar/HBoxContainer/Compass.get_material()
	compassMat.set_shader_param("Angle", compassMat.get_shader_param("Angle") + angle_delta * 7.64)
	
	for slot in get_tree().get_nodes_in_group("PowerupSlots"):
		slot.set_rotation_degrees(slot.get_rotation_degrees() + angle_delta * 100)
		
	for marker in get_tree().get_nodes_in_group("CompassMarkers"):
		marker.update_marker(view_angle)


func _on_powerup_spawned(powerup):
	var marker = markerScene.instance()
	$HeadBar/HBoxContainer/Compass.add_child(marker)
	marker.set_angle(powerup["th"])
	marker.get_material().set_shader_param("MarkerTexture", powerup["type"].icon)
	powerup["marker"] = marker
	var angle = get_tree().get_nodes_in_group("Player")[0].get_facing_angle()
	marker.update_marker(angle)


func _on_powerup_destroyed(powerup):
	powerup["marker"].queue_free()
