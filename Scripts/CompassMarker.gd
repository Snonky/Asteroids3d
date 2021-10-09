extends Control

export(float, 0, 6.28, 0.01) var marker_angle = PI/2 setget set_angle
var current_view_angle = PI/2
var active_range = 0.12 * PI
var visible_range = 0.5 * PI

func angle_between(view_angle):
	var angle = marker_angle - view_angle
	if abs(angle) > PI:
		# Handle wrap around
		angle -= sign(angle) * TAU
	return angle
	

func update_marker(view_angle = current_view_angle):
	current_view_angle = view_angle
	var angle = angle_between(view_angle)
	var relative_angle = angle / active_range
	var offset = 0.0
	var alpha = 0.8
	
	# If the marker is out of view (active range) keep it at the edge of the compass
	if(abs(relative_angle) > 1.0):
		var relative_edge = visible_range / active_range - 1.0
		var relative_edge_angle = (relative_angle - sign(relative_angle)) / relative_edge
		# Slight movement away from the edge
		offset += 80.0 * relative_edge_angle
		# Fade out marker
		alpha = (1.0 - abs(relative_edge_angle)) * 0.5
	
	relative_angle = clamp(relative_angle, -1.0, 1.0)

	offset += 460.0 * relative_angle
	
	get_material().set_shader_param("MarkerOffset", offset)
	get_material().set_shader_param("MarkerAlpha", alpha)
		
func set_angle(newAngle):
	marker_angle = newAngle
	update_marker()
