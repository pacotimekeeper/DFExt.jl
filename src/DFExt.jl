module DFExt

# Write your package code here.
using DataFrames, CSV, XLSX, JLD2
import PyCall
using Base.Threads
import WebTools:read_html
# using Glob
## e.g., export JULIA_NUM_THREADS=4 in the terminal before starting Julia OR set JULIA_NUM_THREADS=4 in the Windows command prompt).
include("csv.jl")
include("excel.jl")
include("jld2.jl")

export to_excel
export ffill

export concat_columns
export read_html
export read_excel, read_excels, to_excel, read_excel_in_chunks
export read_csv, to_csv
export read_jld2, to_jld2
export readExcel

ffill(v) = v[accumulate(max, [i*!ismissing(v[i]) for i in 1:length(v)], init=1)]

function concat_columns(df::DataFrame, column_names::Union{Vector{Symbol}, Vector{String}}, new_column_name::Symbol)::DataFrame
    df[:, new_column_name] = map(eachrow(df)) do row
        join(skipmissing([row[Symbol(col)] for col in column_names]), ", ")
    end
    return df
end


end  # module
