extends Spatial

export(bool) var active = true setget set_active
export(float, 0, 1000) var length : float = 3.0
export(float, 0, 1000) var width : float = 2.0
export(Material) var material : Material
export(Vector2) var segments : Vector2 = Vector2(2, 3)
export(Curve) var length_curve : Curve = Curve.new()
export(Curve) var width_curve : Curve = Curve.new()
export(float) var retraction_speed := 10.0
export(Vector3) var default_velocity := Vector3()

onready var mesh : ImmediateGeometry = $GlobalSpace/Mesh

signal retraction_finished

var positions = []
var vertices = []
var force_retraction = false

func _ready():
	if material != null:
		mesh.material_override = material
	reset_positions()
	
func set_active(new_value):
	active = new_value
	if not active:
		reset_positions()
	
func reset_positions():
	positions = []
	vertices  = []
	# Create all positions
	var pos = base_position(0, global_transform.origin, global_transform.basis.x, 0)
	var offset = 0
	for x in range(segments.x+1):
		positions.append([])
		vertices.append([])
		offset = global_transform.basis.x * segment_width(0) * x
		for _y in range(segments.y+2):
			positions[x].append(pos + offset)
			vertices[x].append(Vector3())
			
func force_retraction():
	force_retraction = true

func _physics_process(delta):
	if(Input.is_mouse_button_pressed(1)):
		pass
		#translate(Vector3(0, 0, -1) * .1)
		#rotate(Vector3.UP, .03)
	if active:
		apply_default_velocity(delta)
		drop_positions(delta)
		draw_mesh()
		
func drop_positions(delta):
	var translations = translations()
	var dists = distances(translations)
	var retract = true
	# Retract the trail when there's no movement
	for d in dists:
		if default_velocity != Vector3.ZERO:
			retract = false
			break
		if d >= 0.001:
			retract = false
			break
	if retract or force_retraction:
		retract(delta)
		return
	var segment_length = 0
	var offset = 0
	for x in range(segments.x+1):
		segment_length = segment_length(x)
		var last_segment = positions[x][0].distance_to(positions[x][1])
		offset = global_transform.basis.x * width/segments.x * x
		var d = dists[x]
		var segment_remaining = min(d, segment_length - last_segment)
		if segment_remaining > 0.0001: # compensating for float inaccuracy
			positions[x][0] -= translations[x].normalized() * segment_remaining
			d -= segment_remaining
		while d > 0.0001:
			var next_segment = min(segment_length, d)
			positions[x].push_front(positions[x][0] - translations[x].normalized() * next_segment)
			positions[x].pop_back()
			d -= next_segment
	correct_last_segment()
	apply_width_curve()

# Reduces last segment in length to maintain the set trail length
func correct_last_segment():
	var segment_length = 0
	for x in range(segments.x+1):
		segment_length = segment_length(x)
		var first_segment = positions[x][0].distance_to(positions[x][1])
		var last_segment_length = segment_length - first_segment
		var last_segment_direction = (positions[x][segments.y+1] - positions[x][segments.y]).normalized()
		positions[x][segments.y+1] = positions[x][segments.y] + last_segment_direction * last_segment_length

func retract(delta):
	var retraction_finished = true
	for x in range(segments.x+1):
		for y in range(1,segments.y+2):
			var d = retraction_speed * delta
			var retraction = positions[x][y-1] - positions[x][y]
			var l = retraction.length()
			if d - l > 0.001:
				d = l
			else:
				retraction_finished = false
			var direction = retraction.normalized()
			var new_position = positions[x][y] + direction * d
			positions[x][y] = new_position
	if retraction_finished:
		force_retraction = false
		emit_signal("retraction_finished")
		

func apply_width_curve():
	if width_curve == null or width_curve.get_point_count() == 0: 
		vertices = positions
		return
	var l = 0
	var c
	for y in range(segments.y+2):
		var direction = positions[segments.x][y] - positions[0][y]
		var center = positions[0][y] + direction * .5
		l += 0 if c == null else center.distance_to(c)
		c = center
		var scale = clamp(width_curve.interpolate_baked(l/length), 0.0, 1.0)
		for x in range(segments.x+1):
			var scaled_point = (positions[x][y] - center) * scale
			vertices[x][y] = center + scaled_point
			
func apply_default_velocity(delta):
	for x in range(segments.x+1):
		for y in range(segments.y+2):
			positions[x][y] -= global_transform.basis * default_velocity * delta

func distances(translations):
	var d = []
	for x in range(segments.x+1):
		var distance = translations[x].length()
		d.append(distance)
	return d
	
func translations():
	var t = []
	var segment_d = segment_width(0)
	var pos = base_position(0, global_transform.origin, global_transform.basis.x, 0)
	var offset = 0
	for x in range(segments.x+1):
		offset = global_transform.basis.x * segment_d * x
		t.append(positions[x][0] - (pos + offset))
	return t

# The base position is the outmost position
func base_position(y, center_pos, direction, v) -> Vector3:
	var half_width = segment_width(v) * segments.x * .5
	var base = center_pos - direction.normalized() * half_width
	return base

# Calculate the length of a segment in the column x with respect to the
# length curve
func segment_length(x):
	var l = 0
	if length_curve != null and length_curve.get_point_count() > 0:
		var scale = clamp(length_curve.interpolate_baked(x/segments.x), 0.01, 1.0)
		l = scale * length/segments.y
	else:
		l = length/segments.y
	return l
	
func segment_width(l):
	var w = 0
	if width_curve != null and width_curve.get_point_count() > 0:
		var scale = clamp(width_curve.interpolate_baked(l), 0.0, 1.0)
		w = scale * width/segments.x
	else:
		w = width/segments.x
	return w
	
func get_uv(x, y):
	var relative_segment = 1.0/segments.y
	var first_segment = positions[x][0].distance_to(positions[x][1]) / segment_length(x) * relative_segment
	
	var uv = Vector2(x * 1.0/segments.x, (y-1) * relative_segment + first_segment)
	if y == 0:
		uv.y = 0
	elif y == segments.y+1:
		uv.y = 1.0
		
	return uv
	
func draw_mesh():
	mesh.clear()
	mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
	for x in range(segments.x):
		for y in range(segments.y+1):
			mesh.set_uv(get_uv(x,y))
			mesh.add_vertex(vertices[x][y])
			mesh.set_uv(get_uv(x+1,y))
			mesh.add_vertex(vertices[x+1][y])
			mesh.set_uv(get_uv(x,y+1))
			mesh.add_vertex(vertices[x][y+1])
			
			mesh.set_uv(get_uv(x+1,y))
			mesh.add_vertex(vertices[x+1][y])
			mesh.set_uv(get_uv(x+1,y+1))
			mesh.add_vertex(vertices[x+1][y+1])
			mesh.set_uv(get_uv(x,y+1))
			mesh.add_vertex(vertices[x][y+1])
	mesh.end()
