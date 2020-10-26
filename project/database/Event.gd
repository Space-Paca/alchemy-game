extends Resource
class_name Event

enum Type {LUCK, CHALLENGE, TRADEOFF, POSITIVE, QUEST}


export(int) var id = 0
export(String) var title = ""
export(String) var text = ""
export(Type) var type = Type.LUCK
export(Dictionary) var floor_appearance = {1: false, 2: false, 3: false}
export(Array, Dictionary) var options = [
		{"button_text": "", "callback": "none", "args": []},
		{"button_text": "", "callback": "none", "args": []},
		{"button_text": "", "callback": "none", "args": []},
		{"button_text": "", "callback": "none", "args": []},
		{"button_text": "", "callback": "none", "args": []},
		{"button_text": "", "callback": "none", "args": []},
		{"button_text": "", "callback": "none", "args": []},
		{"button_text": "", "callback": "none", "args": []},
		{"button_text": "", "callback": "none", "args": []},
		{"button_text": "", "callback": "none", "args": []}]
