extends PolarSpawner

onready var asteroidBody = preload("res://Assets/AsteroidBody.tscn")
onready var cutVfx = preload("res://Assets/cut.tscn")

# Asteroid's rotations around its random rotation axis per second
export(float, 0, 10, .1) var asteroidRotationSpeed = .3


var multimesh
var multimesh_i = 0
# The active angle in the ring is the direction of the player's current view.
# The rest of the ring's calculations (collision and rendering) are culled.
export(float, 0, 6.28, .01) var active_angle = 1.5*PI setget set_active_angle
var active_segment = -1


func _ready():
	multimesh = $AsteroidMultiMesh.multimesh
	multimesh.instance_count = 10000
	multimesh.visible_instance_count = 0

	move_active_segment(.angle_to_segment(active_angle))


func spawn_entity():
	var asteroid = .spawn_entity()
	# Create random rotation axis
	var rotation_axis = Vector3(
		rng.randf()-.5,
		rng.randf()-.5,
		rng.randf()-.5).normalized()
		
	asteroid["basis"] = Basis()
	asteroid["rot_axis"] = rotation_axis

	if segments[asteroid["seg"]]["active"]:
		multimesh.visible_instance_count += 1
		init_asteroid_body(asteroid)


func process_segment(segment, delta):
	# Rotate asteroids
	for asteroid in segment["e"]:
		asteroid["basis"] = asteroid["basis"].rotated(
			asteroid["rot_axis"], delta * 2*PI * asteroidRotationSpeed)
			
	# Draw asteroids with one MultiMesh to save resources
	for asteroid in segment["e"]:
		if !asteroid["alive"]:
			continue
		var translation = polar2cartesian(asteroid["r"], asteroid["th"])
		translation = Vector3(translation.x, 0, translation.y)
		multimesh.set_instance_transform(multimesh_i, Transform(asteroid["basis"], translation))
		multimesh_i += 1


func destroy_entity(asteroid, fx = false):
	var destroyed = .destroy_entity(asteroid)
	if destroyed and segments[asteroid["seg"]]["active"]:
		multimesh.visible_instance_count -= 1
		if(fx):
			play_destruction_fx(asteroid)
		else:
			destroy_asteroid_body(asteroid)

func clean_up_entities():
	.clean_up_entities()
	multimesh_i = 0

func move_active_segment(to_segment):
	# Move the active segment by one position.
	# Passing a segment movement by more than one brings undefined behaviour
	if active_segment == -1:
		# Activate the new active segment
		segments[to_segment]["active"] = true
		# Activate the segments next to it
		var nextSeg = posmod(to_segment + 1, segment_count)
		segments[nextSeg]["active"] = true
		var prevSeg = posmod(to_segment - 1, segment_count)
		segments[prevSeg]["active"] = true
	else:
		# Determine in which direction the active segment moved
		var movement = to_segment - active_segment
		# Wrap around cases
		if movement > 1:
			movement = -1
		elif movement < -1:
			movement = 1
		# Activate/deactivate the segments that moved in/out of view
		var deactivate = posmod(active_segment - movement, segment_count)
		var activate = posmod(to_segment + movement, segment_count)
		segments[deactivate]["active"] = false
		multimesh.visible_instance_count -= segments[deactivate]["e"].size()
		destroy_asteroid_bodies(deactivate)
		segments[activate]["active"] = true
		multimesh.visible_instance_count += segments[activate]["e"].size()
		init_asteroid_bodies(activate)
	active_segment = to_segment


func init_asteroid_body(asteroid):
	if asteroid["alive"]:
		var translation = polar2cartesian(asteroid["r"], asteroid["th"])
		translation = Vector3(translation.x, 0, translation.y)
		var velocity = translation.normalized() * asteroid["speed"]
		var body = asteroidBody.instance()
		add_child(body)
		body.translate(translation)
		body.setup(velocity, asteroid)
		asteroid["body"] = body


func init_asteroid_bodies(segment):
	for asteroid in segments[segment]["e"]:
		init_asteroid_body(asteroid)


func destroy_asteroid_body(asteroid):
	asteroid["body"].queue_free()


func destroy_asteroid_bodies(segment):
	for asteroid in segments[segment]["e"]:
		asteroid["body"].queue_free()
		
		
func play_destruction_fx(asteroid):
	asteroid["body"].get_node("cut/AnimationPlayer").play("Cut")
	
		
func set_active_angle(angle):
	# Culls the asteroids based on the current player view angle
	if active_segment == -1:
		return
	var new_active_angle = angle
	new_active_angle = fposmod(new_active_angle, 2*PI)
	var new_active_segment = angle_to_segment(new_active_angle)
	var current_active_segment = angle_to_segment(active_angle)
	active_angle = new_active_angle
	# Change culled segments when the player enters a new segment
	if new_active_segment != current_active_segment:
		move_active_segment(new_active_segment)


func _on_SpaceFighter_ship_movement(_delta, angle):
	set_active_angle(angle)
