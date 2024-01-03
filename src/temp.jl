
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