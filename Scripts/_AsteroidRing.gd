extends Spatial

export(int) var spawnRadius = 20


onready var asteroid# = preload("res://Assets/test_asteroid.tscn")

var rng = RandomNumberGenerator.new()
export(int, 0, 500) var spawnRate = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if rng.randf() <= delta * spawnRate:
		spawn_asteroid(rng.randf_range(0, 2*PI))

# Instances an asteroid and places it on the spawn radius with angle relative to Vector3.FORWARD
func spawn_asteroid(angle):
	var spawnPoint = Vector3.FORWARD * spawnRadius
	spawnPoint = spawnPoint.rotated(Vector3.UP, angle);
	
	var spawn = asteroid.instance()
	add_child(spawn);
	spawn.translate(spawnPoint)
	
	#Send the asteroid towards the center
	spawn.start_asteroid(-spawnPoint)
