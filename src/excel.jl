

function readExcel(file::AbstractString; sheet_name::Union{AbstractString, Int64}=1, first_row=nothing, infer_eltypes=false)::DataFrame
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

function to_excel(file_name::AbstractString, df::DataFrame)
    XLSX.writetable(file_name, df, overwrite=true)
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


function readbatchxl(path::AbstractString, sheetname::String, skiprows::Int)
    dfs = [readxlsheet(joinpath(path, f), sheetname, skipstartrows = skiprows)[2:end, :] |> DataFrame for f in readdir(path)]
    colnames = [Symbol(colname) for colname in vec(readxlsheet(joinpath(path, readdir(path)[1]), sheetname)[1,:])]
    df = vcat(dfs...)
    names!(df, colnames, makeunique = true)
    return df
end