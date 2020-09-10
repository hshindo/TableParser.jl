mutable struct Table
    caption::String
    data::Vector
end

function Table(caption::String, texts::Vector{PDFText})
    origtexts = texts
    buffer = PDFText[]
    blocks = PDFText[]
    for i = 1:length(texts)
        t = texts[i]
        push!(buffer, t)
        u = i == length(texts) ? nothing : texts[i+1]
        meanw = t.bbox.w / length(t.string)
        if u == nothing || !horizontal(t.bbox,u.bbox) || u.bbox.x > t.bbox.x + t.bbox.w + meanw
            push!(blocks, PDFText(buffer,delim=" "))
            buffer = PDFText[]
        end
    end

    texts = sort(blocks, lt=(t,u) -> (t.bbox.y < u.bbox.y) || (t.bbox.y == u.bbox.y && t.bbox.x < u.bbox.x))
    dict = Dict()
    rowid = 1
    for i = 1:length(texts)
        t = texts[i]
        dict[t] = rowid
        u = i == length(texts) ? nothing : texts[i+1]
        if u == nothing || !horizontal(t.bbox,u.bbox)
            rowid += 1
        end
    end

    texts = sort(blocks, lt=(t,u) -> (t.bbox.w < u.bbox.w) || (t.bbox.w == u.bbox.w && t.bbox.x < u.bbox.x))
    used = Dict()
    id = 1
    columns = Vector{PDFText}[]
    for t in texts
        haskey(used,t) && continue
        used[t] = true
        push!(columns, [t])
        for u in texts
            haskey(used,u) && continue
            if vertical(t.bbox, u.bbox)
                push!(columns[end], u)
                used[u] = true
            end
        end
    end

    sort!(columns, by=c->c[1].bbox.x)
    data = [fill(PDFText(""),length(columns)) for _=1:rowid-1]
    for i = 1:length(columns)
        for t in columns[i]
            data[dict[t]][i] = t
        end
    end
    Table(caption, data)
end
