using FastAmogusCounter
using BenchmarkTools


@time begin
    a = count_amogus("placeprimer.png")
    println('\n', a)
end

@time begin
    a = count_amogus("place.png")
    println('\n', a)
end

println()
display(@benchmark count_amogus("placeprimer.png"))
println()
display(@benchmark count_amogus("place.png"))
println()