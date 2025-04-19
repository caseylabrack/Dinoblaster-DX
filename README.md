# Dinoblaster: 40th Anniversary Edition
An updated and open-source version of [DinoBlaster (1979)](http://store.steampowered.com/app/653960/DinoBlaster/), the extinction-event arcade game with Brontoscan vector graphics.

## Accessibility
DinoBlaster is flashy, spinny, and maybe unreasonably difficult. But you can adjust these things in `settings.txt` by remapping keys, setting `reduceFlashing`, turning off `starsMove`, and changing gameplay values. This game can be played keyboard-only.

## Settings, preferences, and cheats
Edit "settings.txt" to change your controls, set preferences, and even cheat. You can double-click it or launch it from in-game.

See all the settings you can change in the tables below.

Don't worry about messing things up. If DinoBlaster can't read a setting, it'll go with the default. If the whole file is missing or corrupted, it'll just make a new one. (This means a good way to restore all default settings is just delete/rename the file.)

### Controls
Setting | Default value  | Description
:--- |:---|:---
player1LeftKey | a | player 1 (brontosaurus) run counter-clockwise
player1RightKey | d | player 1 (brontosaurus) run clockwise
player2LeftKey | k | player 2 (oviraptor) run counter-clockwise
player2RightKey | l | player 2 (oviraptor) run clockwise
player2UsesArrowKeys | false | should player 2 get the arrow keys? good for playing together on a single keyboard
pauseKey | g | pause or unpause. space bar also toggles pause.
openSettings | t | launch settings.txt in default text editor
triassicSelect | 1 | new game starting in Triassic era (easy difficulty)
jurassicSelect | 2 | new game starting in Jurassic era (medium difficulty). first, beat Triassic era (or cheat using `JurassicUnlocked` setting)
cretaceousSelect | 3 | new game starting in Cretaceous era (hardest difficulty). first, beat Jurassic era (or cheat using `CretaceousUnlocked` setting)
singleplayerMode | o | launch the game in single player mode
multiplayerMode | p | launch the game in two-player mode
sfxVolume | 100 | sound effects volume level, 0–100. At zero, sound effects are muted. 
musicVolume | 100 | music volume level, 0–100. At zero, music is muted. 
hideButtons | false | hides the single player, two-player, and settings buttons (good for a keyboard-only or arcade setup)
hideSidePanels | false | hides all buttons and artwork on the sides of the game
reduceFlashing | false | reduce flashing and disable palette swapping to help with stuff like photosensitive epilepsy
starsMove | true | can be set to false to help with motion sensitivity
glowiness | true | applies a glowy effect, like old vector arcade games had. requires a GPU that can run OpenGL.

### Gameplay
Setting | Default value | Description
:--- |:---|:---
roidsEnabled | true | toggles asteroids. note that this is a game about dodging asteroids. maybe you feel like doing [game tourism](http://vectorpoem.com/tourism/)?
trexEnabled | true | toggle the t-rex in Cretaceous era
volcanosEnabled | true | toggle volcanos in Jurassic era
ufosEnabled | true | toggles visits by the UFOs
tarpitsEnabled | true | toggles tarpits in Jurassic era
hypercubesEnabled | true | toggles the hypercube, a mysterious 4th-dimensional shape that speeds up time when touched
hyperspaceTimeScale | 1.75 | adjust the game pace during hyperspace, the period right after touching the hypercube
hyperspaceDurationInSeconds | 15 | how long should hyperspace last
defaultTimeScale | 1.0 | adjust the game pace. at `2.0`, everything is happening twice as fast. at values like `0.5`, you're in bullet time.
playerSpeed | 3.0 | how fast should the player move?
extraLives | 0 | how many extra lives should the player start with? takes effect next round.
earthRotationSpeed | 2.3 | how fast should the earth spin? very strong effect on difficulty and fun.
earthIsPangea | false | some people demand greater scientific rigor
earthIsWest | true | avoiding Western-centrism
roidsPerSecond | 3 | pace of incoming asteroids
ufoSpawnRateLow | 30 | spawn a UFO at least this often (seconds)
ufoSpawnRateHigh | 90 | spawn a UFO no more than this often (seconds)
trexSpeed | .25 | chase speed of the t-rex
trexAttackAngle | 110 | how far the trex "sees," in degrees
JurassicUnlockedCheat | false | Cheat and play in the Jurassic era without beating the Triassic
CretaceousUnlockedCheat | false | Cheat and play in the Cretaceous era without beating the Jurassic

### Misc
Setting | Default value | Description
:--- |:---|:---
tips | "Real Winners Say No to Drugs","Remember to take breaks" | Text to briefly display at start of game. Should be short and preferably dumb. Put tip in quotes, separate multiple tips with comma
player1Color | "#00ffff" | For two-player mode. Colors should be a hexvalue in quotes (like "#ff00ff") or one of [the html named colors](https://en.wikipedia.org/wiki/Web_colors#Extended_colors) in quotes (like "hotpink")
player2Color | "#ff57ff" | For two-player mode. Colors should be a hexvalue in quotes (like "#ff00ff") or one of [the html named colors](https://en.wikipedia.org/wiki/Web_colors#Extended_colors) in quotes (like "hotpink")
superColorsSwapEvery | 15 | In color-cycling animations, how many frames to hold on each color
superColors | "#ff3800", "#ffff00", "#00ff00", "#00ffff", "#ff57ff" | Colors should be a hexvalue in quotes (like "#ff00ff") or one of [the html named colors](https://en.wikipedia.org/wiki/Web_colors#Extended_colors) in quotes (like "hotpink"). You can have as many colors as you want (separated by comma), or have only "fuchsia", or make a gradient, or whatever you want