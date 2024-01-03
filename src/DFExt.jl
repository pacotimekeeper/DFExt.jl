module DFExt

# Write your package code here.
using DataFrames, CSV, XLSX
import PyCall
using Base.Threads

# using Glob
## e.g., export JULIA_NUM_THREADS=4 in the terminal before starting Julia OR set JULIA_NUM_THREADS=4 in the Windows command prompt).


export read_excel, read_excels
export to_excel
export ffill, fill_missing_headers
export concat_columns
export response_content

ffill(v) = v[accumulate(max, [i*!ismissing(v[i]) for i in 1:length(v)], init=1)]

function fill_missing_headers(headers)
    count = 1
    for (index, value) in enumerate(headers)
        if value == ""
            headers[index] = "missing_"*string(count)
            count += 1
        end
    end
end

function read_excel(file::AbstractString; sheet_name::Union{AbstractString, Int64}=1, first_row=nothing, infer_eltypes=false)::DataFrame
    if endswith(file, "xls")
        pd = PyCall.pyimport("pandas")
        pydf = pd.read_excel(file, 0)
        DataFrames.DataFrame([col => collect(pydf[col]) for col in pydf.columns])
    else
        if infer_eltypes
            DataFrame(XLSX.readtable(file, sheet_name))
        else
            xf = XLSX.readxlsx(file)
            sheet = xf[sheet_name]
            XLSX.eachtablerow(sheet) |> DataFrames.DataFrame
        end
    end
end


function read_excels(dir::AbstractString; sheet_name::Union{AbstractString, Int64}=1)::DataFrame
    files::Vector{String} = filter(file -> endswith(file, ".xlsx"), readdir(dir, join=true))
    df_vector = Vector{DataFrame}(undef, length(files))
 
    @threads for i in 1:length(files)
       df_vector[i] = read_excel(files[i]; sheet_name=sheet_name)
       # df_vector[i] = read_excel(files[i]; sheet_name=sheet_name)
    end
    return vcat(df_vector..., cols:union)
end

function to_excel(df::DataFrame, file_name::AbstractString)
    XLSX.writetable(file_name, df, overwrite=true)
end

function concat_columns(df::DataFrame, column_names::Union{Vector{Symbol}, Vector{String}}, new_column_name::Symbol)::DataFrame
    df[:, new_column_name] = map(eachrow(df)) do row
        join(skipmissing([row[Symbol(col)] for col in column_names]), ", ")
    end
    return df
end

function read_excel_in_chunks(file_path::String, sheet_name::String, chunk_size::Int=1000)::DataFrame
    xls = XLSX.readxlsx(file_path)
    sheet = xls[sheet_name]
    nrows = size(sheet.dimension)[1]

    chunks = []
    for start_row in 1:chunk_size:nrows
        end_row = min(start_row + chunk_size - 1, nrows)
        data = XLSX.readtable(file_path, sheet_name, first_row=start_row, last_row=end_row)
        df_chunk = DataFrames.DataFrame(data...)
        push!(chunks, df_chunk)
    end

    return vcat(chunks...)
end

# function charset(response::HTTP.Messages.Response; default_encoding::AbstractString = "UTF-8") :: AbstractString
#     htmlstr = String(deepcopy(response.body))
#     content = parsehtml(htmlstr).root
#     metatag = Cascadia.matchFirst(sel"meta", content) |> string
#     m = match(r"charset=(.*?)\"", metatag)
#     !isnothing(m) ? m.captures[1] : default_encoding
# end

# function response_content(response::HTTP.Messages.Response, encoding::AbstractString = "UTF-8") ::HTMLElement
#     content = try
#         parsehtml(decode(response.body, encoding)).root
#     catch ## using UTF-8 decoding
#         println("Unable to decode with $(encoding), using UTF-8 instead")
#         parsehtml(String(response.body)).root
#     end
#     content
# end

# function content_type(url::AbstractString) :: Union{AbstractString, Nothing}
#     response = HTTP.get(url)
#     contentBody = String(response.body)
#     pattern = r"charset=(.*?)\""
#     m = match(pattern, contentBody)
#     m !== nothing ? m.captures[1] |> String : nothing
# end

# function html_tables(html::HTMLElement; selector::AbstractString="", startrow=1) ::Vector{AbstractDataFrame}
#     tables = eachmatch(Selector("table$(selector)"), html)
#     dfs = DataFrame[]
#     for table in tables
#         tableRows = eachmatch(sel"tr", table)
#         tableHeader = try
#             text.(tableRows[startrow] |> children)
#         catch
#             continue
#         end
        
#         fill_missing_headers(tableHeader)
#         df = DataFrame(map(th-> th => [], tableHeader), makeunique=true) # create emtpy dataframe with colnames
        
#         for tableRow in tableRows[startrow+1:end]
#             tableData = text.(tableRow |> children)
#             if length(tableData) == length(tableHeader)
#                 push!(df, tableData)
#             end
#         end
#         push!(dfs, df)
#     end
#     dfs
# end

##Usage
# Replace with a list of your Excel files or use Glob.jl to find matching files
# excel_files = glob("*.xlsx")

# Specify the sheet name that you want to read from each Excel file
# sheet_name = "Sheet1"

# Combine the Excel files into a single DataFrame
# combined_df = combine_excel_files(excel_files, sheet_name)

# Print the combined DataFrame
# println(combined_df)

function readbatchxl(path::AbstractString, sheetname::String, skiprows::Int)
    dfs = [readxlsheet(joinpath(path, f), sheetname, skipstartrows = skiprows)[2:end, :] |> DataFrame for f in readdir(path)]
    colnames = [Symbol(colname) for colname in vec(readxlsheet(joinpath(path, readdir(path)[1]), sheetname)[1,:])]
    df = vcat(dfs...)
    names!(df, colnames, makeunique = true)
    return df
end

end  # module
