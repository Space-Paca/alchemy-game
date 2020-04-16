extends Resource
class_name Encounter

export(bool) var is_boss = false
export(int, 1, 3) var level = 1
export(Array, String, "skeleton", "wolf", "robot") var enemies
