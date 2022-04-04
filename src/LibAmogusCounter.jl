using ColorTypes, FixedPointNumbers
using FileIO
using Base.Threads

const PIXEL = RGB{N0f8}
const Strip = SubArray{
    PIXEL,
    2,
    Matrix{PIXEL},
    Tuple{
        UnitRange{Int64},
        UnitRange{Int64}
    },
    false
}
const IDX = CartesianIndex{2}

@inline function lazy_short_circuit(f::F, args::It)::Bool where {F <: Function, It <: Base.Generator}
    all(Iterators.map(f, args))
end

@inline is_valid_amogus_component(pixel::PIXEL, core::PIXEL, should::Bool)::Bool = (pixel == core) == should

@inline is_valid_amogus_component(t::Tuple{PIXEL, PIXEL, Bool})::Bool = is_valid_amogus_component(t...)


@inline function is_amogus(rect::Strip, amogus::BitMatrix, core_colour::PIXEL)::Bool

    @inline getargs(i::Int)::Tuple{PIXEL, PIXEL, Bool} = @inbounds (rect[i], core_colour, amogus[i])

    lazy_short_circuit(is_valid_amogus_component, Iterators.map(getargs, range(1, length(rect))::UnitRange{Int}))
end

function find_amogus(rect::Strip, shapes::Vector{BitMatrix})::Int
    @inbounds for i in range(1, length(shapes))::UnitRange{Int}
        shape::BitMatrix = shapes[i]
        if is_amogus(rect, shape, rect[findfirst(shape)])
            return i
        end
    end
    0
end

@inline function clobber(px::RGBA{N0f8})::UInt32
    let r::UInt32, g::UInt32, b::UInt32, a::UInt32
        r = UInt32(px.r.i) << 24
        g = UInt32(px.g.i) << 16
        b = UInt32(px.b.i) << 8
        a = UInt32(px.alpha.i)
        r | g | b | a
    end
end

const black = RGBA{N0f8}(0, 0, 0, 1)
const PNG = File{format"PNG"}

function get_shapes(shape::PNG)::Vector{BitMatrix}
    img::Matrix{RGBA{N0f8}} = load(shape)
    @inbounds @views begin
        up_right::BitMatrix = img .== black
        up_left::BitMatrix = up_right |> rotl90 |> permutedims

        BitMatrix[
            up_right,
            up_left,
            up_left |> rot180,
            up_right |> rot180
        ]
    end
end

all_forms = BitMatrix[]

function count_amogi(place::PNG, shape::PNG)::Int#Vector{Tuple{IDX, Int}}
    form_index_offset::Int = length(all_forms)
    amogi_shapes::Vector{BitMatrix} = @inbounds get_shapes(shape)
    append!(all_forms, amogi_shapes)

    offset_w, offset_h = size(amogi_shapes[1]) .- 1
    window_offset = IDX(offset_w, offset_h)

    PLACE::Matrix{PIXEL} = RGB.(load(place))
    width, height = size(PLACE)
    locations::Vector{Tuple{IDX, Int}} = Tuple{IDX, Int}[]

    @inbounds @simd for column in range(1, width-offset_w)::UnitRange{Int}
        @inbounds @simd for row in range(1, height-offset_h)::UnitRange{Int}
            start::IDX = IDX(row, column)
            stop::IDX = start + window_offset
            v::Strip = @view PLACE[start:stop]
            #=display(v)
            sleep(1)=#
            r::Int = find_amogus(v, amogi_shapes)
            if r > 0
                @inbounds push!(locations, (start, r+form_index_offset))
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
