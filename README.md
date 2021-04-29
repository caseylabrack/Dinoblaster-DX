# Dinoblaster-DX
An updated and open-source version of [DinoBlaster (1979)](http://store.steampowered.com/app/653960/DinoBlaster/), the extinction-event arcade game with Brontoscan vector graphics. 

## Changing the controls, changing the whole game
Wherever you downloaded DinoBlaster DX, there's a couple text files. `controls-settings.txt` lets you remap the controls. `game-settings.txt` lets you change the rules of the game itself.

Both files are read at game startup. Change the files, restart the game, and the game will be changed! See all the settings you can change below.

The files need to stay in [JSON format](https://en.wikipedia.org/wiki/JSON) (but they're saved as .txt to encourage people to open them). If you mess up the format, the game will replace the file upon next startup. It will do this if the file is missing, too, so a good way to restore default game settings is just to delete the file.

### `controls-settings.txt`
Setting|Possible values (and Default)|Description 
:--- |:---|:---
player1LeftKey | character ("a") | player 1 (brontosaurus) run counter-clockwise
player1RightKey | character ("d") | player 1 (brontosaurus) run clockwise
player2LeftKey | character ("k") | player 2 (oviraptor) run counter-clockwise
player2RightKey | character ("l") | player 2 (oviraptor) run clockwise
player2UsesArrowKeys | true or false (false) | should player 2 get the arrow keys? good for playing together on a single keyboard
triassicSelect | character ("1") | new game starting in Triassic era (easy difficulty)
jurassicSelect | character ("2") | new game starting in Jurassic era (medium difficulty). First, beat Triassic era or change `game-settings.txt`.
cretaceousSelect | character ("3) | new game starting in Cretaceous era (hardest difficulty). First, beat Jurassic era or change `game-settings.txt`

### `game-settings.txt`
Setting|Possible values (and Default)|Description 
:--- |:---|:---
roidsEnabled | true or false (true)| toggles asteroids. note that this is a game about dodging asteroids. maybe you feel like doing [game tourism](http://vectorpoem.com/tourism/)?
hypercubesEnabled | true or false (true) | toggles the hypercube, a mysterious 4th-dimensional shape that speeds up time when touched
ufosEnabled | true or false (true)| toggles UFOs, the way players earn extra lives
defaultTimeScale | positive number (1.0) | Adjust the global rate of events. At `2.0`, everything is happening twice as fast. At values like `0.5`, you're in bullet time.
hyperspaceTimeScale | positive number (1.75) | Adjust the global rate of events during hyperspace, the period right after touching the hypercube
extraLives | positive integer (0) | how many extra lives should the player start with?
earthRotationSpeed | number (2.3) | how fast should the earth spin? very strong effect on difficulty and fun.
playerSpeed | number (5.0) | how fast should the player move? low values are surprisingly fun.
roidImpactRateInMilliseconds | positive number (300) | how do you want to space asteroid impacts? At 1000, an average of one asteroid impact per second.
roidImpactRateVariation | positive number (100) | by how many milliseconds should impacts vary randomly? at 100, the roid impact rate will vary by a tenth of a second from the rate above
JurassicUnlocked| true or false (false) | Cheat and play in the Jurassic era without beating the Triassic
CretaceousUnlocked | true or false (false) | Cheat and play in the Cretaceous era without beating the Jurassic
blurriness | positive number (6) | Blurriness of game monitor. Part of the 1979 vector aesthetic. Requires GPU power to render. Zero to disable effect.
