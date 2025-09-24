using Avdou

function setup(; site_dir = "", public_dir = "public", prefix = "")
    templates = load_templates("templates")
    
    ctx = @context begin
        "prefix" = prefix
        "today" = today()
    end

    site = @site begin
        :site_dir = site_dir

        :public_dir = public_dir
        
        :copies = @copies begin
            @copy begin            
                :pattern = SIMPLE("css/*")
                :route = identity
            end
            
            @copy begin
                :pattern = SIMPLE("content/static/*")
                :route = identity
            end
            
            @copy begin            
                :pattern = SIMPLE("content/static/*/*")
                :route = identity
            end
            
            @copy begin
                :pattern = DIFF("content/teaching/*/*", "content/teaching/*/*.md")
                :route = identity
            end
            
            @copy begin
                :pattern = DIFF("content/activities/*/*", "content/activities/*/*.md")
                :route = identity
            end
        end

        :rules = @rules begin
            @rule begin
                :pattern = DIFF("content/*.md", "content/index.md")
                :filters = [pandoc_md_to_html]
                :templates = @templates begin
                    templates
                    ("section.html", ctx)
                    ("base.html", ctx)
                end
                :route = nice_route
            end
            
            @rule begin
                :pattern = SIMPLE("content/index.md")
                :filters =  [pandoc_md_to_html]
                :templates = @templates begin
                    templates
                    ("index.html", ctx)
                    ("base.html", ctx)
                end
                :route = path -> joinpath(public_dir, "index.html")
            end
            
            @rule begin
                :pattern = SIMPLE("content/teaching/*/*.md")
                :filters = [expand_shortcodes(my_shortcodes, render), pandoc_md_to_html]
                :templates = @templates begin
                    templates
                    ("course.html", ctx)
                    ("base.html", ctx)
                end
                :route =  nice_route
            end
            
            @rule begin
                :pattern = SIMPLE("content/activities/*/*.md")
                :filters =  [pandoc_md_to_html]
                :templates = @templates begin
                    templates
                    ("base.html", ctx)
                end                
                :route = set_extension("html")
            end
        end
    end

    build(site)
        
    #=

    ctx = Context()
    ctx["prefix"] = prefix
    ctx["today"] = today()
    
    copies = [
        Copy(SIMPLE("css/*"), identity),
        Copy(SIMPLE("content/static/*"), identity),
        Copy(SIMPLE("content/static/*/*"), identity),
        Copy(DIFF("content/teaching/*/*", "content/teaching/*/*.md"), identity),
        Copy(DIFF("content/activities/*/*", "content/activities/*/*.md"), identity) 
    ]

    rules = [
        Rule(DIFF("content/*.md", "content/index.md"),
             [pandoc_md_to_html],
             [(templates["section.html"], ctx), (templates["base.html"], ctx)],
             nice_route),
        Rule(SIMPLE("content/index.md"), 
             [pandoc_md_to_html],
             [(templates["index.html"], ctx), (templates["base.html"], ctx)],
             path -> joinpath(public_dir, "index.html")),

        Rule(SIMPLE("content/teaching/*/*.md"),
             [expand_shortcodes(my_shortcodes, render), pandoc_md_to_html],
             [(templates["course.html"], ctx), (templates["base.html"], ctx)],
             nice_route),
        Rule(SIMPLE("content/activities/*/*.md"),
             [pandoc_md_to_html],
             [(templates["base.html"], ctx)],
             set_extension("html"))
    ]

    site = Site(site_dir, public_dir, copies, rules)
    build(site)
    =#
end

### Shortcodes

const my_shortcodes = ["calitem"]

function render(::Val{:calitem}, args)
    """\n~~~{=html}\n<div class=\"box calendar-entry\"><p> <div x-data=\"{ open: false }\">\n<a @click=\"open = ! open\">\n<strong>$(args[1])</strong>\n</a>\n<br><br>\n<div x-show=\"open\">\n~~~\n $(args[2])\n~~~{=html}\n</div>\n</div>\n</p></div>\n~~~\n"""
end

### Utilities
using Dates

function today()
    dt = Dates.today()
    month = monthname(dt)
    "$month $(day(dt)), $(year(dt))"
end
    
