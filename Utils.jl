
const my_shortcodes = ["calitem", "pubitem"]

function render(::Val{:calitem}, args)
    """\n~~~{=html}\n<div class=\"box calendar-entry\"><p> <div x-data=\"{ open: false }\">\n<a @click=\"open = ! open\">\n<strong>$(args[1])</strong>\n</a>\n<br><br>\n<div x-show=\"open\">\n~~~\n $(args[2])\n~~~{=html}\n</div>\n</div>\n</p></div>\n~~~\n"""
end

function render(::Val{:pubitem}, args)
    if length(args) == 4
        """\n<div class=\"cell\">\n $(args[1])\n<br/>\n $(args[2])\n<br/>\n $(args[3])\n<br/>\n $(args[4])\n<br><br>\n</div>\n"""
    elseif length(args) == 3
        """\n<div class=\"cell\">\n $(args[1])\n<br/>\n $(args[2])\n<br/>\n $(args[3])\n<br><br>\n</div>\n"""
    else
        throw("pubitem accepts 3 or 4 arguments. Received $(length(args))")
    end
end

### Utilities
using Dates

function today()
    dt = Dates.today()
    month = monthname(dt)
    "$month $(day(dt)), $(year(dt))"
end

function filetitleminer(doc)
    Context("title" => doc.metadata["title"])
end
