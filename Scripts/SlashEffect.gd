extends Spatial

export(bool) var play setget play
onready var trail = $SwingArm/TrailMesh

func _ready():
	trail.set_active(false)

func play(_b):
	var player = get_node_or_null("SwingArm/AnimationPlayer")
	if player != null and not trail.active:
		player.seek(0, true)
		trail.set_active(true)
		player.play("Slash")

func _on_AnimationPlayer_animation_finished(anim_name):
	trail.force_retraction()

func _on_TrailMesh_retraction_finished():
	trail.set_active(false)
