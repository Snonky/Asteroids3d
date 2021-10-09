extends Spatial

export(PackedScene) var projectile_scene
export(int, 100) var fire_rate = 0 setget set_fire_rate, get_fire_rate
export (float, 0.0, 1.0, 0.001) var fire_delay = 0.0
export(float, 0, 1.5, .0001) var randomRotation = 0.0

var rng = RandomNumberGenerator.new()
var delayed = false

func _ready():
	delayed = fire_delay <= 0
	set_timer()
	rng.randomize()
	
func fire():
	var projectile : Projectile = projectile_scene.instance()
	$Projectiles.add_child(projectile)
	projectile.transform = global_transform
	var random_rot = rng.randf_range(-randomRotation, randomRotation)
	projectile.rotate(Vector3.UP, PI + random_rot)
	projectile.fire(global_transform.basis.z.rotated(Vector3.UP, random_rot))
	
func set_timer():
	if(!get_node_or_null("Timer") or !$Timer.is_inside_tree()): return
	var wait_time = 1.0 / fire_rate
	if !delayed:
		$Timer.set_wait_time(wait_time * fire_delay)
	elif fire_rate > 0:
		$Timer.set_wait_time(wait_time)
	$Timer.start()

func _on_Timer_timeout():
	if delayed:
		fire()
	else:
		delayed = true
		set_timer()

func set_fire_rate(new_val):
	fire_rate = new_val
	set_timer()

func get_fire_rate():
	return fire_rate
