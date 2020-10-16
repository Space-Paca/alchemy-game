extends Resource
class_name Event

enum Type {LUCK, CHALLENGE, TRADEOFF, POSITIVE, QUEST}

export(int) var id = 0
export(String) var name = ""
export(Type) var type = Type.LUCK
export(Dictionary) var floor_appearance = {1: true, 2: true, 3: true}
