# Tanks

Game written in ASM language for 8086 processor.

## How to run it?
1. Download [DosBox](https://www.dosbox.com/)
2. Unzip asm compiler to current directory (tasm.zip)
3. Run DosBox in current directory
4. Mount current directory 
   ```mount T .```
5. Go to mounted drive by typing
   ```T``` (enter)
6. Compile game
   ```
   tasm tanks.asm
   tlink tanks
   ```
7. Run game
   ```tanks.exe```
8. [Optional] Set cpu cycles to change game speed
   ```cycles=7500```