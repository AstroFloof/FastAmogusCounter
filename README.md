# FastAmogusCounter.jl

## What this is
 - fast
 - stupid
 - a sorta usable package
 - a counter for tiny Among Us characters in an image
 - inspired by r/place 2022

## What this isn't
 - serious
 - stable

#### Assets yoinked from [analysus](https://github.com/Feyko/analysus/tree/main/amogi/templates) with Feyko's permission because I wanted to do some Julia and try to compete a bit

## How to use

```julia
using Pkg
pkg"add https://github.com/AstroFloof/FastAmogusCounter.jl.git"
using FastAmogusCounter
count_amogus("path/to/thing.png")
```

## Issues

### I really don't care anymore, I spent too long on this anyway
### Only supports PNGs because I'm lazy and it's faster for now
### There is a commented-out thing that used to save only the amogi in the picture, that isn't working rn due to threading fuckery