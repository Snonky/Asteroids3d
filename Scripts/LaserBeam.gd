extends Projectile

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize();
	
func _process(delta):
	var rand_rot = rng.randf_range(-PI, PI)
	$Head.rotate(Vector3.FORWARD, delta * rand_rot)
