# FastAmogusCounter.jl

## What this is
 - fast 
   - last time I run it it found 2339 amogi in a 2000x2000 image in three seconds, and that was on a 12 year old computer
 - stupid
 - a sorta usable package
 - a counter for tiny Among Us characters in an image
 - inspired by r/place 2022

## What this isn't
 - serious
 - stable

#### Assets yoinked from [analysus](https://github.com/Feyko/analysus/tree/main/amogi/templates) with Feyko's permission because I wanted to do some Julia and try to compete a bit

## How to use

### Option 1
```julia
using Pkg
pkg"add https://github.com/AstroFloof/FastAmogusCounter.jl.git#master"
using FastAmogusCounter
count_amogus("path/to/thing.png")
```
### Option 2
```sh
git clone https://github.com/AstroFloof/FastAmogusCounter.jl.git
cd FastAmogusCounter
julia --project
```
```julia
using Pkg
Pkg.test()
```

## Issues

### I really don't care anymore, I spent too long on this anyway
### Only supports PNGs because I'm lazy and it's faster for now
### There is a commented-out thing that used to save only the amogi in the picture, that isn't working rn due to threading fuckery
