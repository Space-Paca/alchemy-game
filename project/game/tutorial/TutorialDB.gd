extends Node

const TUTORIAL = {
	"first_battle": [
		{"position": Vector2(200,200), "dimension": Vector2(200,200), 
		 "text_side": "top", "text": "This is an example text"},
		{"position": Vector2(500,200), "dimension": Vector2(100,200), 
		 "text_side": "bottom", "text": "This is also a big ada an example text"},
	]
}


func get(name):
	assert(TUTORIAL.has(name), "Not a valid tutorial name: " + str(name))
	return TUTORIAL[name]
