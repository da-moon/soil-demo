# make

## overview

`GNU Make` is used for automating operations.

why ?
- GNU Make is very easy to install in *nix operating systems as it is always included in the package manager.
- GNU Make offers powerful metaprogramming options, such as generating targets dynamically based on folder structure.
- GNU make can run targets concurrently, maximizing speed. It also supports dependency tree for target execution.

Consodering the large number of targets and functions, to make the pipeline more readble, I have split them across multiple files and import them in the main `Makefile`

## directories

- `pkg` : helper utilities, variables and function
- `targets` : main targets imported in repositories' main `Makefile`.
