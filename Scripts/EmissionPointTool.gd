tool
extends CPUParticles

export(bool) var setPoints setget setPoints

func setPoints(_b):
	var points = PoolVector3Array()
	for child in get_children():
		if child is Position3D:
			points.append(child.translation)
	self.set_emission_points(points)
	property_list_changed_notify()

