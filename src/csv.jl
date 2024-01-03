


read_csv(file::AbstractString)::AbstractDataFrame = DataFrame(CSV.File(file))
# test which one is faster later
# read_csv(file::AbstractString)::DataFrames.DataFrame = CSV.read(file, DataFrames.DataFrame)
to_csv(file::AbstractString, df::DataFrame) = CSV.write(file, df)