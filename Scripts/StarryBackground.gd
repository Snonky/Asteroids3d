extends Node

func _on_SpaceFighter_ship_movement(angle):
	var shaderMat = $CanvasLayer/Sprite.get_material()
	shaderMat.set_shader_param("SWAY", shaderMat.get_shader_param("SWAY") + angle * .5)
