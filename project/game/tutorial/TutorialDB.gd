extends Node

const TUTORIAL = {
	"first_battle": [
		{"position": Vector2(40,40), "dimension": Vector2(1680,915), 
		 "text_side": "bottom", "text": "You have found an enemy encounter!"},
		{"position": Vector2(830,80), "dimension": Vector2(880,800), 
		 "text_side": "bottom", "text": "Your objective is to eliminate all enemies\nand not get killed in the process",
		 "text_width": 900},
		{"position": Vector2(250,680), "dimension": Vector2(290,220), 
		 "text_side": "right", "text": "Each turn you'll draw reagents from your bag until you have filled your hand entirely",
		"text_width": 420},
		{"position": Vector2(250,400), "dimension": Vector2(295,295), 
		 "text_side": "top", "text": "You'll drag reagents from your hand to your alchemical grid to craft recipes"},
		{"position": Vector2(795,800), "dimension": Vector2(200,100), 
		 "text_side": "bottom", "text": "You can find your list of recipes clicking here.\nTry it now!",
		"text_width": 500},
	],
	"recipe_book": [
		{"position": Vector2(40,100), "dimension": Vector2(990,1005), 
		 "text_side": "right", "text": "Here you'll find all recipes you've learned or found clues to"},
		{"position": Vector2(780,240), "dimension": Vector2(300,550), 
		 "text_side": "right", "text": "Use these tags to limit recipes you can view,\nsuch as recipes you can make using reagents in your current hand,\nor using everything inside your bag",
		"text_width": 425},
		{"position": Vector2(500,100), "dimension": Vector2(220,100), 
		 "text_side": "right", "text": "The filters will help you find specific recipes when you have learned lots of them",
		"text_width": 420},
		{"position": Vector2(381,480), "dimension": Vector2(314,120), 
		 "text_side": "bottom", "text": "Using a recipe will fill its mastery gauge.\nUse a recipe enough times and you'll unlock a better version of it!",
		"text_width": 420},
		{"position": Vector2(340,180), "dimension": Vector2(420,410), 
		 "text_side": "bottom", "text": "Finally, when you've found a recipe you want to try,\nclick on it.\nTry it now!",
		"text_width": 500},
	],
	"clicked_recipe": [
		{"position": Vector2(250,400), "dimension": Vector2(295,295), 
		 "text_side": "right", "text": "You can now see a blueprint of the recipe you've chosen.\nIt will help you craft it more easily"},
		{"position": Vector2(250,400), "dimension": Vector2(295,295), 
		 "text_side": "right", "text": "Also, clicking on a mastered recipe will craft it for you automatically!"},
		{"position": Vector2(200,400), "dimension": Vector2(395,500), 
		 "text_side": "right", "text": "Drag reagents from your hand to the appropriate places. \nIMPORTANT!\nSome reagents can substitute others,\nhover your mouse on your reagents to find out more about this.",
		"text_width": 425},
		{"position": Vector2(280,840), "dimension": Vector2(260,180), 
		 "text_side": "right", "text": "When you've placed everything, click the combine button or press SPACE!",
		"text_width": 420},
		{"position": Vector2(800,900), "dimension": Vector2(260,120), 
		 "text_side": "top", "text": "When you have nothing else to do,\nor want to hold on to some reagents,\nyou can pass the turn by clicking here.\nYou can also pass your turn by pressing E.",
		"text_width": 850},
		{"position": Vector2(250,680), "dimension": Vector2(290,220),
		 "text_side": "top", "text": "Finally, some important shortcuts!",
		"text_width": 420},
		{"position": Vector2(250,680), "dimension": Vector2(290,220),
		 "text_side": "top", "text": "Right clicking a reagent is extremely useful to move them around faster",
		"text_width": 420},
		{"position": Vector2(800,800), "dimension": Vector2(200,100), 
		 "text_side": "top", "text": "Also, you can open your recipe book with TAB.\nYou can do it outside of battle too!",
		"text_width": 500},
		{"position": Vector2(40,40), "dimension": Vector2(1680,915), 
		 "text_side": "bottom", "text": "Lastly, you can hover your mouse on almost anything to learn more about it",
		 "text_width": 900},
		{"position": Vector2(40,40), "dimension": Vector2(1680,915), 
		 "text_side": "bottom", "text": "Good luck adventurer!",
		 "text_width": 900},
	],
	"map": [
		{"position": Vector2(140,40), "dimension": Vector2(1680,915),
		 "text_side": "bottom", "text": "Welcome to your adventure, alchemist!"},
		{"position": Vector2(620,400), "dimension": Vector2(700,500), 
		 "text_side": "top", "text": "You must explore the land facing monsters,\nlearning alchemical recipes and crafting them along the way",
		"text_width": 1200},
		{"position": Vector2(420,400), "dimension": Vector2(700,500),
		 "text_side": "right", "text": "Find and defeat the land's boss to progress",
		"text_width": 425, "image": "res://game/tutorial/boss-icon.png", "image_scale": 2},
		{"position": Vector2(140,40), "dimension": Vector2(1680,815),
		 "text_side": "bottom", "text": "Exploring and discovering things on your own is part of your journey,\nso don't be afraid to be curious!",
		"text_width": 1500},
		
	]
}


func get(name):
	assert(TUTORIAL.has(name), "Not a valid tutorial name: " + str(name))
	return TUTORIAL[name]
