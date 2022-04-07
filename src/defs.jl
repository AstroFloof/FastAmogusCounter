
using ColorTypes: RGB, RGBA
using FixedPointNumbers: N0f8
using FileIO: File, @format_str

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
const BLACK = RGBA{N0f8}(0, 0, 0, 1)
const PNG = File{format"PNG"}