using FileIO: load
using Base.Threads
import Base.Iterators: repeated as self_iter, Enumerate
include("defs.jl")


@inline function is_valid_amogus_component(pixel::PIXEL, core::PIXEL, should::Bool)::Bool 
    # tests whether the pixel is the same colour as the colour of the
    # potential core of the among us figure, and whether it should be
    (pixel == core) == should
end

function find_amogus(rect::Strip, shape::BitMatrix)::Bool
    @inbounds let core_colour::PIXEL, idxs::CartesianIndices{2, Tuple{Base.OneTo{Int}, Base.OneTo{Int}}}
        core_colour = rect[findfirst(shape)]
        idxs = CartesianIndices(rect)
        @simd for i in idxs
            is_valid_amogus_component(rect[i], core_colour, shape[i]) || return false
        end
    end
    true
end

function get_shapes(shape::PNG)::Vector{BitMatrix}
    @inbounds @views let img::Matrix{RGBA{N0f8}} = load(shape)
        up_right::BitMatrix = img .== BLACK
        up_left::BitMatrix = up_right |> rotl90 |> permutedims

        BitMatrix[
            up_right,
            up_left,
            up_left |> rot180,
            up_right |> rot180
        ]
    end
end

function count_amogi_iter(PLACE::Matrix{PIXEL}, shape::PNG)::Int

    height, width = size(PLACE)

    locations::Vector{Tuple{IDX, Int}} = Tuple{IDX, Int}[]

    flipped_amogi::Vector{BitMatrix} = @inbounds get_shapes(shape)

    for (i, shape) in enumerate(flipped_amogi)::Enumerate{Vector{BitMatrix}}

        offset_h, offset_w = size(shape) .- 1

        rows = 1:height-offset_h
        cols = 1:width-offset_w
       
        @views for column in cols::UnitRange{Int}, row in rows::UnitRange{Int}

            v::Strip = PLACE[row:row+offset_h, column:column+offset_w]

            find_amogus(v, shape) && @inbounds push!(locations, (IDX(row, column), i))

        end
    end
    locations |> length
    #=
    onlymogus = similar(PLACE)

    @time @inbounds @views for corner in locations::Vector{Tuple{IDX, Int}}
        idx, type = corner::Tuple{IDX, Int}
        onlymogus[idx:idx+window_offset][amogus_masks[type]] .= PLACE[idx:idx+window_offset][amogus_masks[type]]
    end
    save("./src/onlymogus.png", onlymogus)
    println.(locations)
    =#
end


function count_amogi(place::PNG, shapes::Vector{PNG})::Int

    PLACE::Matrix{PIXEL} = PIXEL.(load(place))
    
    # Variables for each thread to avoid race conditions (doesn't seem to be necessary)
    # PLACE_COPIES = #=SMatrix{c, r, PIXEL, c*r}=#Matrix{PIXEL}[deepcopy(PLACE) for _ in 1:nthreads()]
    counts::Vector{Int} = fill(0, nthreads())

    # Threaded loop
    @threads for s in shapes
        t = threadid()
        count_part = count_amogi_iter(PLACE, s)
        counts[t] += count_part
    end

    return sum(counts)
end