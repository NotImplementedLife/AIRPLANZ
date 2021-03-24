# AIRPLANZ

Multiplayer Gameboy ROM written in Assembly

## How to build

```
rgbasm -o main.o source\main.asm
rgblink -o AIRPLANZ.gb main.o
rgbfix -v -p 0 AIRPLANZ.gb
```

## Run

```
bgb64 AIRPLANZ.gb
```