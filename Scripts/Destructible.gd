extends KinematicBody
class_name Destructible

export(int) var _HP = 100


func damage(d):
	if _HP > 0:
		_HP -= d
		if _HP <= 0:
			destroy()
	
	
func heal(d):
	_HP += d
	
	
func destroy():
	# Override this function
	pass
