extends Spatial

func play():
	if($AnimationPlayer.get_current_animation() == ""):
		$AnimationPlayer.play("SlashAnimation")
