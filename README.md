# Alchemia: Creatio Ex Nihilo

###### A turn-based roguelike in which the player collects alchemical reagents and combines them into magical recipes to battle against outlandish foes.
<hr>

![background](https://user-images.githubusercontent.com/3944304/136468775-28ce327c-be15-47d6-aa25-5d0a3e864320.png)

Welcome to the land of Alchemia, where magic and alchemy meet to create fantastical creatures and allow explorers to harness powers only dreamt of! In your journeys through this land you'll encounter foes, friends, ancient knowledge and relics from a bygone civilization, and much more!

## Mechanics overview

The game resembles deckbuilder roguelikes, such as Slay the Spire, but with an interesting twist. In our game you start with a few reagents and recipes and collect more as you explore and overcome encounters against enemies. To battle you combine reagents in a grid, with each reagent having a different effect such as dealing damage and protecting against enemies' attacks. However the magic really happens when you combine more than one reagent on specific positions on the grid into a recipe, resulting in a stronger effect than using the standalone reagents. Recipes always have the same reagent requirements but their reagents' positions are randomized at the start of each run, so players have to either find the recipes again on a new run or attempt to guess their reagent layout, risking failing the recipe and having the reagents only produce their standalone effect.

## How to run

You can download the game for your platform of choice in our [releases page](https://github.com/Space-Paca/alchemy-game/releases), or download the project and run it in the [Godot](https://godotengine.org/download) game engine (version 3.4). From version 0.4.0 onwards we added Spine animations, so in order to run the project from inside the engine you'll need to [build Godot from source](https://docs.godotengine.org/en/stable/development/compiling/index.html) along with rayxuln's [Spine Runtime for Godot Engine](https://github.com/rayxuln/spine-runtime-for-godot).

## How to play

Drag reagents to your grid with left click or right click to send them straight to the first available position. When you're satisfied with your grid's layout click on combine (or press enter) to see the effects of your combination. When you have no more reagents or want to save them for a later turn click on end turn (or press e) and the enemies will have their turn. You can check what recipes you have available by clicking on "Recipe book" (or pressing TAB), and if you click on one you have already discovered its layout appears on the grid to make combining easier (right clicking reagents during this state will send them to the correct position for the selected recipe).

## The team

**Ricardo Fonseca** ([@rilifon](https://github.com/rilifon)) - Game Designer & Programmer

**Arthur Vieira** ([@arthurtui](https://github.com/arthurtui)) - Game Designer & Programmer

**Licinio Souza** - Artist

**Rodrigo Passos** ([@passosteps](https://github.com/passosteps)) - Audio Designer & Musician
