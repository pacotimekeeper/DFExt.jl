
readarrow(filepath::AbstractString)::DataFrame = Arrow.Table(filepath) |> DataFrame |> copy
toarrow(filepath::AbstractString, df::DataFrame) = Arrow.write(filepath, df)