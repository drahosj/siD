# Objective
Standalone VM capable of executing compiled Dis bytecode. The main goal is not
necessarily to port the Inferno OS, but rather to create a portable, embeddable
Dis VM.

# Dependencies
No `dub` dependencies for now; targeting portability to -betterC

# Building and Running
Currently, the only build artifact is basically an executable that loads a .dis
file and prints a bunch of debug stuff.

With `dub` and a D compiler (`ldc2` recommended):

```
dub build

```
# Why?
You're not the police; you can't stop me.
