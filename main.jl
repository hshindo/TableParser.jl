include("rectangle.jl")
include("pdf.jl")
include("table.jl")
include("html.jl")

dir = ARGS[1]
for file in readdir(dir)
    endswith(file,".pdf") || continue
    pdffile = "$dir/$file"
    jsonfile = "$pdffile.tables.json"
    isfile(jsonfile) || continue

    println(pdffile)
    try
        texts = readpdf(pdffile)
        tables = parse_tables(texts, jsonfile)
        html = join(map(toHTML,tables), "\n")
        writeHTML(html, "$pdffile.html")
        println("Success")
    catch e
        println(e)
    end
end
