
module FastAmogusCounter

    import Base.Threads: nthreads, threadid, @threads, Atomic, atomic_add!

    const PACKAGE_ROOT = normpath(joinpath(@__DIR__, ".."))
    const SRC_DIR = joinpath(PACKAGE_ROOT, "src")
    const SHAPES_DIR = joinpath(SRC_DIR, "shapes")
    const TEST_DIR = joinpath(PACKAGE_ROOT, "test")

    include("./LibAmogusCounter.jl")

    shape_files = PNG[
        PNG(joinpath(SHAPES_DIR, "$name.png")) for name in String[
                "3x5",
                "4x4-short-backpack",
                "4x4",
                "4x5-long-backpack",
                "4x5-low-backpack",
                "4x5-mini-backpack-up",
                "4x5-mini-backpack",
                "4x5",
                "4x6-big-backpack-longboi",
                "4x6-mini-backpack",
                "4x6-slim-mini-backpack",
                "4x6-slim-small-backpack",
                "4x6-slim",
                "4x6-small-backpack-up",
                "4x6-small-backpack",
                "4x6"
        ]
    ]

    export count_amogus
    function count_amogus(filename::String)::Int

        image = PNG(filename)

        global count = Atomic{Int}(count_amogi(image, shape_files[1]))

        @threads for s in shape_files[2:end]::Vector{PNG}
            global count
            count_part = count_amogi(image, s)
            atomic_add!(count, count_part)
        end

        return count[]

    end
end