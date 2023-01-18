extends Resource
class_name PlayerClass

export(String) var name
export(Array, String) var initial_recipes
export(Array, Array) var initial_reagents #Pair of String (name) and Int (amount)
export(Array, int) var max_hps = [100, 180, 250]
