extends Reference

var cap setget set_capacity, get_capacity
var arr = []

# A class for a circular array
func _init(capacity : int):
	cap = capacity
	
# The newest added element always lands at index 0, overwriting the oldest
func add(element):
	arr.push_front(element)
	if size() > cap: arr.pop_back()

# get(0) returns the most recent element
func get(i):
	if(size() <= i):
		return null
	else:
		return arr[i]
		
func set(i, element):
	if(size() <= i):
		return null
	else:
		arr[i] = element
		
func size() -> int:
	return arr.size()
	
func set_capacity(new_cap : int):
	if(new_cap < 0): return
	if(new_cap < cap):
		for _i in range(cap - new_cap):
			arr.pop_back()
	
	cap = new_cap
	
func get_capacity() -> int:
	return cap

