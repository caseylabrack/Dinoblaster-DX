# Dinoblaster-DX
An updated and open-source version of [DinoBlaster (1979)](http://store.steampowered.com/app/653960/DinoBlaster/), the extinction-event arcade game with Brontoscan vector graphics.

## Settings, preferences, and cheats (DIP switches)
There's a file called `DIP-switches.txt` in the folder where you download DinoBlaster. Edit this text file to change your controls, set preferences, and even cheat.

The DIP switches file is read at game startup. Change the file, restart the game, and the game will be changed! See all the settings you can change in the tables below.

Don't worry about messing things up. If DinoBlaster can't read a setting, it'll go with the default. If the whole file is missing or corrupted, it'll just make a new one. (This means a good way to restore all default settings is just delete/rename the file.)

### Controls
Setting|Possible values (and Default)|Description
:--- |:---|:---
player1LeftKey | character ("a") | player 1 (brontosaurus) run counter-clockwise
player1RightKey | character ("d") | player 1 (brontosaurus) run clockwise
player2LeftKey | character ("k") | player 2 (oviraptor) run counter-clockwise
player2RightKey | character ("l") | player 2 (oviraptor) run clockwise
player2UsesArrowKeys | true or false (false) | should player 2 get the arrow keys? good for playing together on a single keyboard
triassicSelect | character ("1") | new game starting in Triassic era (easy difficulty)
jurassicSelect | character ("2") | new game starting in Jurassic era (medium difficulty). first, beat Triassic era (or cheat using `JurassicUnlocked` setting)
cretaceousSelect | character ("3") | new game starting in Cretaceous era (hardest difficulty). first, beat Jurassic era (or cheat using `CretaceousUnlocked` setting)
sfxVolume | number (100) | sound effects volume level, 0–100. at zero, sound effects are muted. volume control is not guaranteed to work on all devices, but muting should always work
musicVolume | number (100) | music volume level, 0–100. at zero, music is muted. volume control is not guaranteed to work on all devices, but muting should always work
startAtLevel | number (4) | what level plays when the game starts (and restarts). values of 0 and 1 make the game start at triassic; 2 at jurassic; 3 at cretaceous; and 4, the default, chooses the highest level unlocked
hideDIPSwitchesButton | true or false (false) | toggles the options button. options button allows users to change some controls from within game using a click or tap. on devices without a click or tap (like arcade cabinet setups), choose true
glowiness | positive number (30) | Glowiness of game monitor. Setting of 0 is crisp; 15 is glowy; 30 is sparkly; 60 looks old and dusty. Non-zero setting requires OpenGL (it might not work on the Raspberry Pi, depending on your version).

### Gameplay
Setting|Possible values (and Default)|Description
:--- |:---|:---
roidsEnabled | true or false (true)| toggles asteroids. note that this is a game about dodging asteroids. maybe you feel like doing [game tourism](http://vectorpoem.com/tourism/)?
trexEnabled | true or false (true) | toggle the T-Rex in Cretaceous era
volcanosEnabled | true or flase (true) | toggle volcanos in Jurassic era
ufosEnabled | true or false (true)| toggles UFOs, the way players earn extra lives
hypercubesEnabled | true or false (true) | toggles the hypercube, a mysterious 4th-dimensional shape that speeds up time when touched
hyperspaceDuration | positive number (15) | how long should hyperspace last (in seconds)
hyperspaceTimeScale | positive number (1.75) | adjust the game pace during hyperspace, the period right after  touching the hypercube
defaultTimeScale | positive number (1.0) | adjust the game pace. At `2.0`, everything is happening twice as fast. At values like `0.5`, you're in bullet time.
playerSpeed | number (5.0) | how fast should the player move? low values are surprisingly fun.
extraLives | positive integer (0) | how many extra lives should the player start with?
earthRotationSpeed | number (2.3) | how fast should the earth spin? very strong effect on difficulty and fun.
earthIsPangea | true or false (false) | some people have pointed out that the earth didn't look like that then
earthIsWest | true or false (true) | avoiding Western-centrism
roidImpactRateInMilliseconds | positive number (300) | how do you want to space asteroid impacts? At 1000, an average of one asteroid impact per second.
roidImpactRateVariation | positive number (100) | by how many milliseconds should impacts vary randomly? at 100, the roid impact rate will vary by a tenth of a second from the rate above
JurassicUnlocked| true or false (false) | Cheat and play in the Jurassic era without beating the Triassic
CretaceousUnlocked | true or false (false) | Cheat and play in the Cretaceous era without beating the Jurassic
