extends Spatial
# Class for spawning entities on a radius and moving them on towards/from the
# center
class_name PolarSpawner

# Amount of radial chunks in the spawner.
# The entities will be assigned to chunks by their spawn angle like cake slices.
export(int, 4, 360, 1) var segment_count = 100
# Radius at which the spawn points are
export(int) var spawn_radius = 40
# Inner radius at which the asteroids despawn
export(int) var inner_despawn_radius = 10
# Outer radius at which the asteroids despawn
export(int) var outer_despawn_radius = 70
# Spawned entities per second
export(float, 0.0, 1000.0) var spawn_rate = 20
# Default speed of spawned entites. Negative values for moving inwards.
export(int) var default_speed = 3

var rng = RandomNumberGenerator.new()
var spawn_counter = 0

# List of segments
var segments = []
# Entites to be removed in the next clean up cycle
var destroyed_entities = []


func _ready():
	rng.randomize()

	for s in segment_count:
		# Each segment is a dictionary
		segments.append({
			# If the segment is active and will be processed
			# Movement and spawning occurs in all segments
			"active": false,
			# List of entities in the segment
			"e": []
		})
		
		
func _process(delta):
	# Move process
	move_entites(delta)
	
	clean_up_entities()
	
	# Spawning process
	var spawn_amount = delta * spawn_rate + spawn_counter
	var whole_spawn_amount = int(spawn_amount)
	# Carry the fractional spawns to the next frame
	spawn_counter = spawn_amount - whole_spawn_amount
	for s in whole_spawn_amount:
		spawn_entity()
		
	# Individual segment processing
	for s in segments:
		if s["active"]:
			process_segment(s, delta)
	
	
func spawn_entity():
	# Determine random angle to spawn the new entity on
	var th = 2*PI * rng.randf_range(0.0,.99999)
	# Calculate segment of the angle
	var seg = angle_to_segment(th)
	
	var entity = {
		# Angle theta in the ring
		"th": th,
		# Distance r from the center
		"r": spawn_radius,
		"speed": default_speed,
		"alive": true,
		"seg": seg
	}
	
	segments[seg]["e"].append(entity)
	return entity
	
	
func move_entites(delta):
	for s in segments:
		for entity in s["e"]:
			if entity["alive"]:
				entity["r"] += delta * entity["speed"]
				if (entity["r"] > outer_despawn_radius 
				or entity["r"] < inner_despawn_radius):
					destroy_entity(entity)
	
	
func destroy_entity(entity):
	# Mark entity for clean up
	if entity["alive"]:
		entity["alive"] = false
		destroyed_entities.append(entity)
		return true
	return false
	
	
func clean_up_entities():
	# Clean up destroyed entites
	for e in destroyed_entities:
		segments[e["seg"]]["e"].erase(e)
	destroyed_entities.clear()
	
	
func process_segment(segment, delta):
	# Override for segment processing
	pass
	
	
func angle_to_segment(th):
	return int(th / (2*PI/segment_count))
