export toHTML

function escapeHTML(s::String)
    s = replace(s,  "&"=>"&amp;")
    s = replace(s, "\""=>"&quot;")
    s = replace(s,  "'"=>"&#39;")
    s = replace(s,  "<"=>"&lt;")
    s = replace(s,  ">"=>"&gt;")
    s
end

function toHTML(table::Table)
    caption = escapeHTML(table.caption)
    trs = map(table.data) do r
        s = join(map(t -> "<td>$(escapeHTML(t.string))</td>", r))
        "<tr>$s</tr>"
    end
    html = join(trs, "\n")
    """
    <table>
    <caption>$caption</caption>
    $html
    </table>
    """
end

function writeHTML(body::String, filename::String)
    css = open(io -> read(io,String), joinpath(@__DIR__,"style.css"))
    html = """
    <!DOCTYPE html>
    <html>
    <head>
    <meta charset="utf-8">
    <style type="text/css">
    $css
    </style>
    </head>
    <body>
    $body
    </body>
    </html>
    """
    open(filename,"w") do io
        println(io, html)
    end
end
