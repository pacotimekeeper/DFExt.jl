module DFExt

# Write your package code here.
using DataFrames, CSV, XLSX, JLD2
using HTTP, Gumbo, Cascadia

import PyCall
using Base.Threads
# using Glob
## e.g., export JULIA_NUM_THREADS=4 in the terminal before starting Julia OR set JULIA_NUM_THREADS=4 in the Windows command prompt).
include("csv.jl")
include("excel.jl")
include("jld2.jl")


export ffill, concatColumns

export read_csv, to_csv, readCSV, toCSV
export read_excel, read_excels, to_excel, read_excel_in_chunks
export readExcel, toExcel
export toexcel

export read_jld2, to_jld2, readJLD2, toJLD2
export htmlTables
export readexcel

ffill(v) = v[accumulate(max, [i*!ismissing(v[i]) for i in 1:length(v)], init=1)]

function concatColumns(df::DataFrame, columnNames::Union{Vector{Symbol}, Vector{String}}, newColumnName::Symbol)::DataFrame
    df[:, newColumnName] = map(eachrow(df)) do row
        join(skipmissing([row[Symbol(col)] for col in columnNames]), ", ")
    end
    return df
end

function htmlTables(html::HTMLElement; selector::AbstractString="", startRow=1)::Vector{AbstractDataFrame}
    function fillMissingHeaders(headers)
        count = 1
        for (index, value) in enumerate(headers)
            if value == ""
                headers[index] = "missing_"*string(count)
                count += 1
            end
        end
    end
    
    tables = eachmatch(Selector("table$(selector)"), html)
    dfs = DataFrame[]
    for table in tables
        tableRows = eachmatch(sel"tr", table)
        tableHeaders = try
            text.(tableRows[startRow] |> children)
        catch
            continue
        end
        
        fillMissingHeaders(tableHeaders)
        df = DataFrame(map(th-> th => [], tableHeaders), makeunique=true) # create emtpy dataframe with colnames
        
        for tableRow in tableRows[startRow+1:end]
            tableData = text.(tableRow |> children)
            if length(tableData) == length(tableHeaders)
                push!(df, tableData)
            end
        end
        push!(dfs, df)
    end
    dfs
end


# function readHTML(response::HTTP.Messages.Response; selector::AbstractString="", startRow=1)::Vector{AbstractDataFrame}
#     # content = response_content(response, charset(response))
#     content = responseContent(response)
#     htmlTables(content, selector=selector, startRow=startRow)
# end

end  # module
