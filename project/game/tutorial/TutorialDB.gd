extends Node

const TUTORIAL = {
	"first_battle": [
		{"position": Vector2(200,200), "dimension": Vector2(200,200)},
		{"position": Vector2(500,200), "dimension": Vector2(100,200)}
	]
}


func get(name):
	assert(TUTORIAL.has(name), "Not a valid tutorial name: " + str(name))
	return TUTORIAL[name]
