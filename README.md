# Tactical Naval Warfare Game Prototype 

I have always been fascinated with history, particularly influenced by my AP US History class, Dan Carlin's podcst "Hardcore History", and my current favorite, Everett Rummage's "Age of Napoleon" podcast.
When I found Montemayor's video series, ["The Battle of Midway 1942: Told from the Japanese Perspective (1/3)"](https://www.youtube.com/watch?v=Bd8_vO5zrjo), I became fascinated by naval history.

During this highly detailed documentary of the battle of Midway, he presents naval warfare as a cat-and-mouse game of limited information, with intelligence limited by factors such as scout planes getting lost, misidentifying ships, and naval codes playing major roles in victory and defeat.

With this project, I sought to simulate this environment of tense tactical decisions with limited informaiton. The current prototype has implemented the basics of naval combat, torpedo planes, plane pathfinding, and navigation. Future directions include team-based multiplayer, with each player taking on a unique role such as Air Controller, Fleet Admiral, Squadron Commander, and Signals Intelligence.

## Running Instructions:
1. Download Godot (version 3) from this website: https://godotengine.org/download/archive/3.5-stable/
2. Open the project file (project.godot) in Godot.
3. Press "Start Game".
4. Add as many destroyers and carriers as you would like.
5. Proceed to the map.
6. Basic controls:
  - Space to pause the game. Escape to pull up the game menu, where you can quit the game or return to the main menu. 
  - Left-click or drag-click to select a unit (or multiple units). Left-clicking outside a unit will deselect it. 
  - Right-click to issue a movement order. Dragging the right mouse button orders a unit to rotate at the end of its movement. If multiple ships are selected, they will move in formation (i.e. keep the spacing between one another). If you hold down the "option" key and right click when multiple ships are selected, they will all move to the same point.
  - "Shift" to queue an action.
  - "Q" to begin patrolling (going between two points). 
  - Speed controls:
    - "S" - standard ahead
    - "H" - half speed
    - "F" - flank speed
    - "B" - stop.
  - Carrier / plane launch controls:
    - Select a carrier, press a plane key, and right click to issue a plane launch order. Planes cannot be controlled after being launched.
    - "Z" - strike planes (torpedo bombers, modelled after the TBF Avenger). These will automatically launch torpedoes at the closest visible enemy ship within range. 
    - "X" - Scout planes (modelled after PBY Catalina boats). These are sent out in an arc. 
    - "C" - Fighter plane patrol (very roughly modelled after the F4F Wildcat). Cannot launch other planes while fighters are patrolling.
    - "V" - High-altitude level bomber (modelled after the B29 Superfortress, even though this came much later in the war). 
    - "N" - Stop current launch.
    - Note: Plane-to-plane combat is not implemented yet.
  - Experimental features:
    - While these are implemented, they are not fully functional yet – there are some issues with movement orders and ship path rendering that comes up when the camera is moved around. 
    - "+" and "-" to zoom in and out.
    - Arrow keys to move the camera. 
