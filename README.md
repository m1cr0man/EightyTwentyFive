# 80x25

Random bundle of applications and scripts. Windows, Linux, and CraftOS.
Mostly console based.


## Table of Contents

1. [ComputerCraft Software](#computercraft-software)
	- [Stateful](#stateful)
	- [Shockwave](#shockwave)
	- [Areacut](#areacut)
	- [Keyboard Turtle Control](#keyboard-turtle-control)


## ComputerCraft Software

These are Lua programs wrote specifically for use with the Minecraft mod
[ComputerCraft](http://www.computercraft.info), which adds computers and
"turtle" robots to the game.

### Stateful

Allows turtle applications to resume where they left off by wrapping the turtle
library and logging the return value of each function call, in order, to disk.

When the program is resumed the turtle commands will be "fast forwarded" to the
point where the program closed by sending these same return values again.

This works for most turtle programs but does not cover user interaction or
the rednet library.

#### Usage

Run the program either in your scripts through `shell.run` or manually at the
command prompt. This will wrap the turtle API globally.

### Shockwave

Strip mining software. Digs out a Nx1x3 tunnel in a square pattern, expanding
outwards like a shockwave.

- Handles liquids and falling blocks properly
- Places torches
- Drops useless materials, or waits for user to collect some
- Attempts auto refueling, asks users otherwise

#### Usage

Place turtle on bottom left of first square. It will turn right as it runs.

```
shockwave <Num-Waves> <Starting-Width> <Wave-Gap> [<Starting-Ring>]
```

- `Num-Waves`: The number of squares to mine out, cascading outwards.
	- Default: 5
- `Starting-Width`: The width of the first square.
	- Default: 4
- `Wave-Gap`: The size of the gap between each wave.
	- Default: 2
- `Starting-Ring`: Optional, the ring the turtle is starting on. Used when
expanding an existing shockwave mine
	- Default: 1

### Areacut

Mines out a square area.

- Handles liquids and falling blocks properly
- Calculates fuel cost before starting and prompts for fuel if necessary
- Uses [Stateful](#stateful) - reboot friendly

#### Usage

Place turtle on top left or top right of first square, facing into the area.

```
areacut <Front> <Left/Right> <Down>
```

- `Front`: The distance to dig infront of the turtle
	- Minimum: 2
- `Left/Right`: The distance to dig left of the turtle. Negative for right
	- Minimum: +/-2
- `Down`: The distance to dig down
	- Minimum: 2

**NOTE:** All measurements include the block the turtle is on.

### Keyboard Turtle Control

Allows the user to move the turtle using their keyboard whilst in the console.

The controls as well as the blocks detected above, below and infront of the
turtle are printed on the screen.

#### Usage

Run the program normally on a turtle. The on-screen controls should guide you
from there.
