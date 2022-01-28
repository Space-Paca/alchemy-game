extends Resource
class_name Event

enum Type {LUCK, CHALLENGE, TRADEOFF, POSITIVE, QUEST}


export(int) var id = 0
export(String) var title = ""
export(Texture) var image
export(String, "event_bloody_bet", "event_positive") var bgm = "event_bloody_bet"
export(String, MULTILINE) var text = ""
export(String, MULTILINE) var leave_text_1 = ""
export(String, MULTILINE) var leave_text_2 = ""
export(String, MULTILINE) var leave_text_3 = ""
export(String, MULTILINE) var leave_text_4 = ""
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
