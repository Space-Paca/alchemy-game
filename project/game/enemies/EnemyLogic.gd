
class_name EnemyLogic

var cur_state_ = null
var states_ = {}

func get_current_state():
	return cur_state_

func set_state(state):
	assert(states_[state])
	cur_state_ = state
	
func add_state(name):
	states_[name] = {"connections":[],}

func add_connection(state1, state2, weight, bidirectional = false):
	assert(states_[state1] and states_[state2])
	states_[state1].connections.append({"state":state2, "weight":weight})
	if bidirectional:
		states_[state2].connections.append({"state":state1, "weight":weight})

#Update cur_state giving its connections, using weight as probability
func update_state():
	var connections = states_[cur_state_].connections
	if connections.size() == 0:
		return cur_state_
	var total_weight = 0
	for link in connections:
		total_weight += link.weight
	
	randomize()
	var rand_weight = randi()%(total_weight+1)
	for link in connections:
		rand_weight -= link.weight
		if rand_weight <= 0:
			set_state(link.state)
			return link.state
	
	print("Something went wrong, shouldn't be here")
	assert(false)

#For debugging purposes
func print_states():
	for state in states_:
		print(state)
		print("Connections:")
		for link in states_[state].connections:
			print(link.state, " ", link.weight)
