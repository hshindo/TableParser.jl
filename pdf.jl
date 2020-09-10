using CodecZlib
using JSON

mutable struct PDFText
    string::String
    page::Int
    bbox::Rectangle
    texts::Vector{PDFText}
end

PDFText(string::String) = PDFText(string, 0, Rectangle(), PDFText[])

function PDFText(texts::Vector{PDFText}; delim="")
    @assert !isempty(texts)
    string = join(map(t -> t.string, texts), delim)
    bbox = merge(map(t -> t.bbox, texts))
    PDFText(string, texts[1].page, bbox, texts)
end

function readpdf(pdffile::String)
    @assert endswith(pdffile,".pdf")
    textfile = pdffile * ".txt.gz"
    if !isfile(textfile)
        run(`java -classpath ../pdfextractor.jar TextExtractor input=$pdffile`)
    end

    lines = open(s -> readlines(GzipDecompressorStream(s)), textfile)
    texts = PDFText[]
    words = PDFText[]
    for line in lines
        isempty(line) && continue
        items = Vector{String}(split(line,'\t'))
        page = parse(Int, items[1])
        # str = Unicode.normalize(items[2], :NFKC)
        str = items[2]
        bbox = map(x -> parse(Float64,x), split(items[3]," "))
        bbox = Rectangle(bbox...)
        t = PDFText(str, page, bbox, PDFText[])
        push!(texts, t)
        delim = items[4]
        if delim == "S" || delim == "N"
            push!(words, PDFText(texts))
            texts = PDFText[]
        end
    end
    words
end

function parse_tables(texts::Vector{PDFText}, jsonfile::String)
    json = JSON.parsefile(jsonfile)
    i = 1
    tables = Table[]
    for dict in json
        page = dict["page"]
        bbox = Rectangle(dict["x"], dict["y"], dict["w"], dict["h"])
        tabletexts = filter(t -> t.page == page && contains(bbox,t.bbox), texts)
        caption = "Table $i"
        table = Table(caption, tabletexts)
        push!(tables, table)
        i += 1
    end
    tables
end
