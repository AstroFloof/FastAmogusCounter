using FileIO: load
import Base.Iterators: zip as iter_zip, repeated as self_iter, Enumerate
include("defs.jl")

@inline function lazy_short_circuit(f::F, args::Iterators.Zip)::Bool where {F <: Function}
    all(Iterators.map(f, args))
end

@inline is_valid_amogus_component(pixel::PIXEL, core::PIXEL, should::Bool)::Bool = (pixel == core) == should

@inline is_valid_amogus_component(t::Tuple{PIXEL, PIXEL, Bool})::Bool = is_valid_amogus_component(t...)


@inline function is_amogus(rect::Strip, amogus::BitMatrix, core_colour::PIXEL)::Bool
    lazy_short_circuit(is_valid_amogus_component, iter_zip(rect, self_iter(core_colour), amogus))
end

function find_amogus(rect::Strip, shape::BitMatrix)::Bool
    is_amogus(rect, shape, rect[@inbounds findfirst(shape)])
end

function get_shapes(shape::PNG)::Vector{BitMatrix}
    img::Matrix{RGBA{N0f8}} = load(shape)
    @inbounds @views begin
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


function count_amogi(place::PNG, shape::PNG)::Int #Vector{Tuple{IDX, Int}}

    PLACE::Matrix{PIXEL} = RGB.(load(place))
    height, width = size(PLACE)

    locations::Vector{Tuple{IDX, Int}} = Tuple{IDX, Int}[]

    amogi_shapes::Vector{BitMatrix} = @inbounds get_shapes(shape)

    for (i, shape) in enumerate(amogi_shapes)::Enumerate{Vector{BitMatrix}}

        offset_h, offset_w = size(shape) .- 1

        cols = 1:width-offset_w
        rows = 1:height-offset_h


        for column in cols::UnitRange{Int}, row in rows::UnitRange{Int}

            v::Strip = @view PLACE[row:row+offset_h, column:column+offset_w]

            if find_amogus(v, shape)::Bool
                @inbounds push!(locations, (IDX(row, column), i))
            end

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
    println.(locations)=#
end
