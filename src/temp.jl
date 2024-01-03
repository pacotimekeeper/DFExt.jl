
# export read_csv
# export read_excel, read_excels, read_excels_d, write_excel
# export read_table
# export combine_excels
# export combine_excel_files_threads

# function combine_excel_files(files::Vector{String}, sheet_name::String)::DataFrame
#     combined_df = DataFrames.DataFrame()
#     for file in files
#         df = read_excel_in_chunks(file, sheet_name)
#         combined_df = vcat(combined_df, df)
#     end
#     return combined_df
# end

# function combine_excels(dir::AbstractString; sheet_name::Union{AbstractString, Int64}=1, data_type_cvt=false)
#    dfs = [read_excel(file; sheet_name, data_type_cvt) for file in readdir(dir, join=true, sort=true) if endswith(file, ".xlsx")]
#    vcat(dfs...)
# end

# function combine_excel_files_threads(files::Vector{String}, sheet_name::String)::DataFrame
#     combined_df = DataFrame()
#     dfs = Vector{DataFrame}(undef, length(files))

#     # Spawn a new thread for each file to read in chunks
#     for (i, file) in enumerate(files)
#         dfs[i] = Threads.@spawn read_excel_in_chunks(file, sheet_name)
#     end

#     # Combine the DataFrames from each thread
#     for i in 1:length(files)
#         combined_df = vcat(combined_df, fetch(dfs[i]))
#     end

#     return combined_df
# end

# readcsv(file::AbstractString)::AbstractDataFrame = DataFrame(CSV.File(file))
# read_csv(file::AbstractString)::DataFrames.DataFrame = CSV.read(file, DataFrames.DataFrame)

# tocsv(df::DataFrame, filename::AbstractString) = CSV.write(filename, df)

# function readcsvs(path::AbstractString)::AbstractDataFrame
#     dfs = [readcsv(joinpath(path, file)) for file in readdir(path) if endswith(file, ".csv")]
#     vcat(dfs..., cols=:union)
# end


# function freadcsvs(path::AbstractString)::AbstractDataFrame
#     files = [joinpath(path, file) for file in readdir(path) if endswith(file, ".csv")]

#     vdfs = map(_ -> [], 1:Threads.nthreads())
#     @Threads.threads for file in files
#         push!(vdfs[Threads.threadid()], readcsv(file))
#     end

#     vcat(append!(vdfs...)..., cols=:union)
# end


# function combine_csvs(files, dst)
#     open("$dst.csv", "w") do output
#         isfirst = true
#         for file in files
#            open(file, "r") do input
#               if isfirst
#                  println(output, readline(input))
#                  isfirst=false
#               else
#                  readline(input)      # read repeated CSV header but
#                  println(output)      # print carriage return only
#               end
#               buf = Vector{UInt8}(undef, 262144)   # L1 cache: 262144 => 252 s; 32768 => 323 s
#               while !eof(input)
#                  nb = readbytes!(input, buf)
#                  write(output, view(buf,1:nb))
#               end
#            end
#         end
#      end
# end


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