struct Rectangle
    x::Float64
    y::Float64
    w::Float64
    h::Float64
end

Rectangle() = Rectangle(0.0, 0.0, 0.0, 0.0)

Base.string(r::Rectangle) = join([r.x,r.y,r.w,r.h], " ")

function Base.show(io::IO, r::Rectangle)
    print(io, string(r))
end

function contains(r::Rectangle, s::Rectangle)
    r.x <= s.x || return false
    r.x + r.w >= s.x + s.w || return false
    r.y <= s.y || return false
    r.y + r.h >= s.y + s.h || return false
    true
end

function merge(rects::Vector{Rectangle})
    minx, miny = rects[1].x, rects[1].y
    maxx, maxy = rects[1].x+rects[1].w, rects[1].y+rects[1].h
    for r in rects
        r.x < minx && (minx = r.x)
        r.y < miny && (miny = r.y)
        r.x+r.w > maxx && (maxx = r.x+r.w)
        r.y+r.h > maxy && (maxy = r.y+r.h)
    end
    Rectangle(minx, miny, maxx-minx, maxy-miny)
end
merge(rects::Rectangle...) = merge([rects...])

function horizontal(r::Rectangle, s::Rectangle)
    r.y > s.y && return horizontal(s,r)
    r.y + r.h > s.y + 0.5(s.h) &&
    s.y < r.y + 0.5(r.h)
end

function vertical(r::Rectangle, s::Rectangle)
    r.x > s.x && return vertical(s,r)
    r.x + r.w - s.x > min(r.w,s.w) / 2
end

function isblock(r::Rectangle, s::Rectangle)
    abs(r.h-s.h) < 0.3
end
