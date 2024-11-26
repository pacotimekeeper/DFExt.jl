

read_jld2(file::AbstractString)::DataFrame = load_object(file)
to_jld2(file::AbstractString, df::DataFrame) = save_object(file, df)


readjld2(file::AbstractString)::DataFrame = load_object(file)
tojld2(file::AbstractString, df::DataFrame) = save_object(file, df)

readJLD2(file::AbstractString)::DataFrame = load_object(file)
toJLD2(file::AbstractString, df::DataFrame) = save_object(file, df)