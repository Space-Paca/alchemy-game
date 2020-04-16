extends Resource
class_name Encounter

export(bool) var is_boss
export(int, 1, 3) var level = 1
export(Array, String, "skeleton") var enemies
