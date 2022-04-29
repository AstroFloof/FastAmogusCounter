using FastAmogusCounter
using BenchmarkTools
using Test


macro force_display(e...)
    esc(
        quote 
            display.(eval.($e)) 
            println()
        end
    )
end


@time begin
    a = count_amogus("placeprimer.png")
    @test a == 0
    println('\n', a)
end

@time begin
    a = count_amogus("place.png")
    @test a == 2339
    println('\n', a)
end


@force_display @benchmark count_amogus("placeprimer.png")

@force_display @benchmark count_amogus("place.png")


include("../src/LibAmogusCounter.jl")
include("../src/defs.jl")
tmppng = PNG("../src/shapes/4x4.png")

@force_display @benchmark @inbounds get_shapes(tmppng)