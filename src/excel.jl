

function read_excel(source::AbstractString; sheetName::Union{AbstractString, Int64}=1, first_row=nothing, infer_eltypes=false)::DataFrame
    if endswith(source, "xls")
        pd = PyCall.pyimport("pandas")
        pydf = pd.read_excel(source, 0)
        DataFrames.DataFrame([col => collect(pydf[col]) for col in pydf.columns])
    else
        if infer_eltypes
            DataFrame(XLSX.readtable(source, sheetName))
        else
            xf = XLSX.readxlsx(source)
            sheet = xf[sheetName]
            XLSX.eachtablerow(sheet) |> DataFrames.DataFrame
        end
    end
end


function read_excels(dir::AbstractString; sheetName::Union{AbstractString, Int64}=1)::DataFrame
    sources::Vector{String} = filter(file -> endswith(file, ".xlsx"), readdir(dir, join=true))
    df_vector = Vector{DataFrame}(undef, length(sources))
 
    @threads for i in 1:length(sources)
       df_vector[i] = read_excel(sources[i]; sheetName=sheetName)
       # df_vector[i] = read_excel(sources[i]; sheetName=sheetName)
    end
    return vcat(df_vector..., cols:union)
end

function read_excel_in_chunks(source::String, sheetName::String, chunk_size::Int=1000)::DataFrame
    xls = XLSX.readxlsx(source)
    sheet = xls[sheetName]
    nrows = size(sheet.dimension)[1]

    chunks = []
    for start_row in 1:chunk_size:nrows
        end_row = min(start_row + chunk_size - 1, nrows)
        data = XLSX.readtable(source, sheetName, first_row=start_row, last_row=end_row)
        df_chunk = DataFrames.DataFrame(data...)
        push!(chunks, df_chunk)
    end

    return vcat(chunks...)
end


function readbatchxl(path::AbstractString, sheetname::String, skiprows::Int)
    dfs = [readxlsheet(joinpath(path, f), sheetname, skipstartrows = skiprows)[2:end, :] |> DataFrame for f in readdir(path)]
    colnames = [Symbol(colname) for colname in vec(readxlsheet(joinpath(path, readdir(path)[1]), sheetname)[1,:])]
    df = vcat(dfs...)
    names!(df, colnames, makeunique = true)
    return df
end

function to_excel(source::AbstractString, df::DataFrame)
    XLSX.writetable(source, df, overwrite=true)
end


function readExcel(source::AbstractString; sheetName::Union{AbstractString, Int64}=1, 
        first_row::Union{Nothing, Int} = nothing, 
        infer_eltypes::Bool=false)::DataFrame

    if endswith(source, "xls")
        pd = PyCall.pyimport("pandas")
        pydf = pd.read_excel(source, 0)
        DataFrames.DataFrame([col => collect(pydf[col]) for col in pydf.columns])
    else
        if inferEltypes
            DataFrame(XLSX.readtable(source, sheetName; first_row = firstRow, infer_eltypes = inferEltypes))
        else
            xf = XLSX.readxlsx(source)
            sheet = xf[sheetName]
            XLSX.eachtablerow(sheet) |> DataFrames.DataFrame
        end
    end
end

function toExcel(source::AbstractString, df::DataFrame)
    XLSX.writetable(source, df, overwrite=true)
end

function readexcel(filepath::T, sheetname::T; args...) where T <: AbstractString
    if endswith(filepath, "xls")
        pd = PyCall.pyimport("pandas")
        pydf = pd.read_excel(source, 0)
        DataFrames.DataFrame([col => collect(pydf[col]) for col in pydf.columns])
    else
        DataFrame(XLSX.readtable(source, sheetname; args...))
   end
end

function toexcel(source::AbstractString, df::DataFrame)
    XLSX.writetable(source, df, overwrite=true)
end