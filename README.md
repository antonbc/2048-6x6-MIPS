# 2048 Game in MIPS Assembly

This project is a enhanced version of the 4x4 grid 2048 game created by Gabrielle Cirulli, solely implemented in MIPS assembly which is designed to be run using the MARS software. The project is essentially a console version of the original 2048 game. The game features a 6x6 grid rather than the original 4x4 2048 game however, it is still capped at 2048 instead of 8192. Additionally, instead of pressing the up, down, right, and left keys the game uses W,S,D, and A respectfully. Another feature unique to the project, is the option to enable and disable the generation of a new random tile. Lastly, an undo feature is also implemented, wherein the user has the option to undo a single move with the input of 'z'. The game ends in a win if the player achieves a 2048 tile or in a loss if the player fills the board up and no possible moves can be made.


## Requirements

1. Java Runtime Environment (JRE), Java 9 or higher. Latest Java SE recommended.
https://www.oracle.com/java/technologies/javase-downloads.html

2. **MARS application**
https://courses.missouristate.edu/KenVollmar/MARS/MARS_4_5_Aug2014/Mars4_5.jar

## Features

- **Customizable Game Start**: Players can start with a new game or provide a custom 6x6 board configuration.
- **Tile Movements**: Players can use `W`, `A`, `S`, `D` keys to swipe tiles in different directions. The game merges identical tiles and shifts them appropriately, displaying the board after each move.
- **Random Tile Addition**: A new tile (with a value of 2) is added to an empty cell after each move. Players can disable or enable this feature during gameplay by entering specific commands.
- **Win and Loss Conditions**: If a tile with 2048 appears, the player wins. If no moves are possible on a fully occupied board, the player loses.
- **Game End**: Entering ‘X’ at any time will end the game gracefully.

## Game Mechanics

1. **Tile Swiping and Merging**: Tiles move and merge based on the chosen direction. Swipes are blocked by grid edges or other tiles, similar to the original 2048 rules.
2. **Move Commands**:
   - `A`: Swipe left
   - `D`: Swipe right
   - `W`: Swipe up
   - `S`: Swipe down
   - `3`: Disable random tile generation
   - `4`: Enable random tile generation
   - `X`: End the game
   - `z`: Undo single move
3. **Win Condition**: A tile with 512 signifies a win, ending the game.
4. **Loss Condition**: A fully occupied board with no possible moves results in a game-over message.



## Installation and Setup

### 1. MARS Setup
Download and install the [MARS MIPS Simulator](http://courses.missouristate.edu/KenVollmar/mars/).

### 2. Running the Game (with GUI)

- Place the `fivetwelve.asm` file in your MARS projects folder.
- Open MARS and run the `fivetwelve.asm` file to play the game.

### 3. Running the Game (via Terminal)

If you prefer to run the game from the terminal without the GUI, use the MARS JAR file to execute the MIPS code.

- Ensure you are in the directory containing the `Mars4_5.jar` file and the `fivetwelve.asm` file.
- Run the following command:

    ```bash
    java -jar Mars4_5.jar sm nc fivetwelve.asm 
    ```
#### Flags:
- `sm`: Forces MARS to start execution from the `main` label. Without this, MARS will start execution from the first instruction in the file.
- `nc`: Disables the MARS copyright message from being displayed in the standard output.
- `Mars4_5.jar`: Is the location where it is stored hence, adjust it via `../` if it is located in the parent folder.

### 4. Running the Game in MacOS

macOS users may want to add `-Dapple.awt.UIElement=true` after `java` to prevent minor window-switching inconveniences regarding the Dock.

```bash
java -Dapple.awt.UIElement=true -jar Mars4_5.jar sm nc fivetwelve.asm 
```

### 5. Running the Game with Input Redirection

You can automate user input by feeding input directly from a file. For example, if you have an `input.txt` file with the required input lines, you can run:

```bash
java -jar Mars4_5.jar sm nc fivetwelve.asm < input.txt
